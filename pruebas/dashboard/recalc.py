"""
Recalcula tampconfig_pyramid.xml, OMPL_RRTConnect_pyramid_ur3.xml y
orientaciones_finales_normalizadas.txt a partir de posiciones.txt.

Reproduce a mano alzada el mismo procedimiento que se ha venido aplicando
manualmente: normalizar los ángulos articulares (grados -> variables
articulares de Kautham) y convertir las posiciones TCP de almacenamiento
(mm, marco del robot) a coordenadas X/Y de Kautham.
"""

import re
from decimal import ROUND_HALF_UP, Decimal
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
POSICIONES_FILE = REPO_ROOT / "posiciones.txt"
TAMPCONFIG_FILE = REPO_ROOT / "config" / "tampconfig_pyramid.xml"
OMPL_FILE = REPO_ROOT / "problem" / "OMPL_RRTConnect_pyramid_ur3.xml"
ORIENT_FINALES_FILE = REPO_ROOT / "orientaciones_finales_normalizadas.txt"

N_CUBES = 10
ROBOT_BASE_X = 0.37

JOINT_NAMES = [
    "ur3_right_shoulder_pan_joint",
    "ur3_right_shoulder_lift_joint",
    "ur3_right_elbow_joint",
    "ur3_right_wrist_1_joint",
    "ur3_right_wrist_2_joint",
    "ur3_right_wrist_3_joint",
]


def parse_posiciones(path=POSICIONES_FILE):
    """Lee posiciones.txt y devuelve (orientaciones_iniciales, orientaciones_finales, posiciones_iniciales),
    cada una una lista de 10 filas (C1..C10) en el mismo orden que aparecen en el fichero."""
    text = path.read_text(encoding="utf-8")
    sections = {"Orientaciones Iniciales": [], "Orientaciones Finales": [], "Posiciones Iniciales": []}
    current = None
    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line:
            continue
        if line in sections:
            current = line
            continue
        if current is not None:
            sections[current].append([float(v.replace(",", ".")) for v in line.split()])

    for name, rows in sections.items():
        if len(rows) != N_CUBES:
            raise ValueError(
                f"Se esperaban {N_CUBES} filas en la sección '{name}' de {path.name}, "
                f"se encontraron {len(rows)}"
            )

    return sections["Orientaciones Iniciales"], sections["Orientaciones Finales"], sections["Posiciones Iniciales"]


def _round3(value):
    """Redondea a 3 decimales con la convención 'half up' (como se ha hecho a mano durante
    todo el proyecto), evitando que la imprecisión de coma flotante de round() de Python
    cambie valores como 0.2495 -> 0.249 en lugar de 0.250."""
    return float(Decimal(str(value)).quantize(Decimal("0.001"), rounding=ROUND_HALF_UP))


def normalize_joints(degs):
    """Normaliza 6 ángulos (grados) a variables articulares de Kautham (0-1) y añade la pinza (0.813, cerrada).
    El codo (índice 2) tiene periodo de 360 grados; el resto, de 720."""
    norm = []
    for i, d in enumerate(degs[:6]):
        period = 360.0 if i == 2 else 720.0
        norm.append(_round3(d / period + 0.5))
    norm.append(0.813)
    return norm


def storage_position(col1, col2):
    """Convierte una posición TCP (mm, marco del robot) a coordenadas X/Y del mundo de Kautham."""
    x = _round3(ROBOT_BASE_X - col1 / 1000.0)
    y = _round3(-col2 / 1000.0)
    return x, y


def _format_controls(values):
    return " ".join(f"{v:.3f}" for v in values)


def update_tampconfig(pick_norms, place_norms, positions, path=TAMPCONFIG_FILE):
    with open(path, "r", encoding="utf-8", newline="") as f:
        text = f.read()

    for i in range(1, N_CUBES + 1):
        x, y = positions[i - 1]

        text, n = re.subn(
            rf'(<Object name="C{i}"\s+kthname="cube{i}">)\s*[-\d.]+\s+[-\d.]+(\s*0\.025 0 0 0 1</Object>)',
            lambda m: f"{m.group(1)}   {x:.3f} {y:.3f}{m.group(2)}",
            text,
        )
        if n != 1:
            raise ValueError(f"No se encontró el <Object> de C{i} en {path.name}")

        text, n = re.subn(
            rf'(<Pick robot="ROBOT1" object="C{i}" region="STORAGE">.*?<GraspControls grasp="topgrasp">)'
            rf"\s*[-\d.\s]+(</GraspControls>\s*</Pick>)",
            lambda m: f"{m.group(1)} {_format_controls(pick_norms[i - 1])} {m.group(2)}",
            text,
            flags=re.S,
        )
        if n != 1:
            raise ValueError(f"No se encontró el <Pick> de C{i} en {path.name}")

        text, n = re.subn(
            rf'(<Place robot="ROBOT1" object="C{i}" region="PYRAMID">.*?<GraspControls grasp="topgrasp">)'
            rf"\s*[-\d.\s]+(</GraspControls>\s*</Place>)",
            lambda m: f"{m.group(1)} {_format_controls(place_norms[i - 1])} {m.group(2)}",
            text,
            flags=re.S,
        )
        if n != 1:
            raise ValueError(f"No se encontró el <Place> de C{i} en {path.name}")

    with open(path, "w", encoding="utf-8", newline="") as f:
        f.write(text)


def update_ompl(pick_norms, positions, path=OMPL_FILE):
    with open(path, "r", encoding="utf-8", newline="") as f:
        text = f.read()

    for i in range(1, N_CUBES + 1):
        x, y = positions[i - 1]
        text, n = re.subn(
            rf'(<KauthamName name="cube{i}" />\s*<Home TH="0\.0" WZ="1\.0" WY="0\.0" WX="0\.0" Z="0\.025" Y=")'
            rf'[-\d.]+(" X=")[-\d.]+(" />)',
            lambda m: f"{m.group(1)}{y:.3f}{m.group(2)}{x:.3f}{m.group(3)}",
            text,
        )
        if n != 1:
            raise ValueError(f"No se encontró el <Home> de cube{i} en {path.name}")

    # La query de ejemplo usa el Pick de C1
    c1 = pick_norms[0]
    for name, value in zip(JOINT_NAMES, c1[:6]):
        text, n = re.subn(
            rf'(<RobotControl name="{name}"\s+init="[\d.]+" goal=")[-\d.]+(" />)',
            lambda m: f"{m.group(1)}{value:.3f}{m.group(2)}",
            text,
        )
        if n != 1:
            raise ValueError(f"No se encontró el RobotControl '{name}' en la query de ejemplo de {path.name}")

    with open(path, "w", encoding="utf-8", newline="") as f:
        f.write(text)


def update_orientaciones_finales_doc(place_norms, finales_deg, path=ORIENT_FINALES_FILE):
    lines = [
        "Orientaciones Finales Normalizadas (Place GraspControls)",
        "Formato: shoulder_pan  shoulder_lift  elbow  wrist_1  wrist_2  wrist_3  gripper",
        "Normalizacion: elbow -> (rad + pi) / (2*pi)  |  resto -> (rad + 2*pi) / (4*pi)",
        "Gripper fijo a 0.813 (cerrado)",
        "",
    ]
    for i in range(N_CUBES):
        label = f"C{i + 1}:"
        lines.append(f"{label:<5}" + "  ".join(f"{v:.3f}" for v in place_norms[i]))
    lines.append("")
    lines.append("--- Orientaciones originales en grados (posiciones.txt) ---")
    for i in range(N_CUBES):
        label = f"C{i + 1}:"
        lines.append(f"{label:<5}" + " ".join(f"{v:7.2f}" for v in finales_deg[i]))

    path.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="")


def recalc_all():
    """Lee posiciones.txt y actualiza tampconfig, OMPL y el fichero de documentación de orientaciones finales.
    Devuelve (pick_norms, place_norms, positions) por si se quieren inspeccionar."""
    iniciales_deg, finales_deg, posiciones_mm = parse_posiciones()

    pick_norms = [normalize_joints(row) for row in iniciales_deg]
    place_norms = [normalize_joints(row) for row in finales_deg]
    positions = [storage_position(row[0], row[1]) for row in posiciones_mm]

    update_tampconfig(pick_norms, place_norms, positions)
    update_ompl(pick_norms, positions)
    update_orientaciones_finales_doc(place_norms, finales_deg)

    return pick_norms, place_norms, positions


if __name__ == "__main__":
    recalc_all()
    print("Recálculo completado: tampconfig_pyramid.xml, OMPL_RRTConnect_pyramid_ur3.xml "
          "y orientaciones_finales_normalizadas.txt actualizados desde posiciones.txt.")

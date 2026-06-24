"""
Dashboard centralizado del proyecto.

Encadena, desde un único menú, todos los pasos manuales que se han venido
haciendo por separado: recalcular tampconfig/OMPL desde posiciones.txt,
sincronizarlos con el workspace de ROS2, lanzar la simulación de
Kautham/ktmpb, traer de vuelta el taskfile resultante y regenerar UR3.py.

Funciona tanto si ROS2/Kautham están en WSL (Windows) como si están en Linux
nativo, macOS, o si este propio dashboard se ejecuta ya dentro de WSL/Linux;
ver el interruptor USE_WSL en config.py.

La ejecución del programa en el robot real queda fuera de este dashboard
y se sigue haciendo a mano (ejecutando UR3.py por separado).

Antes de usarlo, debe editarse config.py con las rutas del ordenador correspondiente.
"""

import subprocess
import sys
from pathlib import Path

import config
import recalc

REPO_ROOT = Path(__file__).resolve().parent.parent


def windows_to_wsl_path(win_path: str) -> str:
    """Convierte una ruta de Windows (p.ej. C:\\Users\\...) a su equivalente montado en WSL (/mnt/c/Users/...)."""
    drive, rest = win_path.split(":", 1)
    rest = rest.replace("\\", "/")
    return f"/mnt/{drive.lower()}{rest}"


def repo_shell_path() -> str:
    """Ruta del repositorio en la notación que entienda el bash donde se ejecutan los comandos
    (convierte de Windows a WSL si USE_WSL=True; si no, asume que ya está en notación Linux/macOS)."""
    if config.USE_WSL:
        return windows_to_wsl_path(config.REPO_PATH)
    return config.REPO_PATH


def run_shell(command: str, check: bool = True) -> int:
    """Ejecuta un comando de shell, en WSL (si USE_WSL=True) o directamente con bash
    (Linux nativo, macOS, o si este propio dashboard ya se ejecuta dentro de WSL/Linux)."""
    if config.USE_WSL:
        full_cmd = ["wsl", "-d", config.WSL_DISTRO, "--", "bash", "-c", command]
    else:
        full_cmd = ["bash", "-c", command]
    print(f"\n$ {command}\n")
    result = subprocess.run(full_cmd)
    if check and result.returncode != 0:
        raise RuntimeError(f"El comando terminó con código {result.returncode}")
    return result.returncode


def action_recalc():
    print("Recalculando tampconfig/OMPL a partir de posiciones.txt...")
    recalc.recalc_all()
    print("Hecho: tampconfig_pyramid.xml, OMPL_RRTConnect_pyramid_ur3.xml y "
          "orientaciones_finales_normalizadas.txt actualizados.")


def action_sync_to_wsl():
    repo = repo_shell_path()
    scenario = config.scenario_folder_path()
    ff_domains = f"{scenario}/ff-domains"
    cmd = (
        f'cp "{repo}/config/tampconfig_pyramid.xml" "{scenario}/tampconfig_pyramid.xml" && '
        f'cp "{repo}/problem/OMPL_RRTConnect_pyramid_ur3.xml" "{scenario}/OMPL_RRTConnect_pyramid_ur3.xml" && '
        f'cp "{repo}/pddl/pyramiddomain.pddl" "{ff_domains}/pyramiddomain.pddl" && '
        f'cp "{repo}/pddl/pyramidproblem.pddl" "{ff_domains}/pyramidproblem"'
    )
    run_shell(cmd)
    print("Ficheros sincronizados con el workspace de ROS2.")


def action_run_simulation():
    scenario = config.scenario_folder_path()
    cmd = (
        f'cd "{config.WS_TAMP_PATH}" && '
        # bash -c no es interactivo y no carga ~/.bashrc, así que hay que
        # sourcear el underlay de ROS2 a mano para que "ros2" esté en el PATH.
        f'source "{config.ROS_SETUP_BASH}" && '
        f"colcon build --symlink-install && "
        f"source install/setup.bash && "
        f"ros2 launch ktmpb_client ktmpb_full.launch.py test:=true "
        f"models_folder_path:={config.MODELS_FOLDER_PATH} "
        f'scenario_folder_path:="{scenario}" '
        f"tamp_config_filename:={config.TAMP_CONFIG_FILENAME}"
    )
    run_shell(cmd)


def action_copy_taskfile_back():
    repo = repo_shell_path()
    scenario = config.scenario_folder_path()
    cmd = (
        f'cp "{scenario}/taskfile_tampconfig_pyramid.xml" '
        f'"{repo}/taskfile/taskfile_tampconfig_pyramid.xml"'
    )
    run_shell(cmd)
    print("Taskfile copiado de vuelta al repositorio (taskfile/taskfile_tampconfig_pyramid.xml).")


def action_generate_ur3py():
    robot_dir = REPO_ROOT / "robot"
    print("Regenerando UR3.py desde el taskfile...")
    subprocess.run([sys.executable, "generador_UR_xml.py"], cwd=robot_dir, check=True)


def action_run_all():
    action_recalc()
    action_sync_to_wsl()
    action_run_simulation()
    action_copy_taskfile_back()
    action_generate_ur3py()
    print("\nFlujo completo terminado. UR3.py está listo para ejecutarse en el robot (paso manual, aparte).")


MENU = [
    ("Recalcular tampconfig/OMPL desde posiciones.txt", action_recalc),
    ("Sincronizar tampconfig/OMPL con el workspace de ROS2", action_sync_to_wsl),
    ("Ejecutar la simulación Kautham/ktmpb (colcon build + ros2 launch)", action_run_simulation),
    ("Copiar el taskfile resultante al repositorio", action_copy_taskfile_back),
    ("Regenerar UR3.py desde el taskfile", action_generate_ur3py),
    ("Ejecutar todo el flujo anterior en orden (1 -> 5)", action_run_all),
]


def print_menu():
    print("\n=== Dashboard RA Manipulador ===")
    for i, (label, _) in enumerate(MENU, start=1):
        print(f"{i}. {label}")
    print("0. Salir")


def main():
    while True:
        print_menu()
        choice = input("\nEscoja una opción: ").strip()
        if choice == "0":
            break
        try:
            index = int(choice) - 1
            if index < 0 or index >= len(MENU):
                raise ValueError
        except ValueError:
            print("Opción no válida.")
            continue

        _, action = MENU[index]
        try:
            action()
        except Exception as exc:  # se sigue mostrando el menú aunque falle un paso
            print(f"\n¡Ha fallado el paso! {exc}")


if __name__ == "__main__":
    main()

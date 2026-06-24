"""
Configuración del dashboard.

Cada usuario debe ajustar las rutas absolutas de este fichero a su
propio ordenador antes de usar el dashboard. Las rutas relativas dentro del
propio repositorio no hace falta cambiarlas, deberían mantenerse iguales sin 
importar el dispositivo.
"""

# Cómo se ejecutan los comandos de ROS2/Kautham (colcon, ros2 launch, cp...):
#   - True  -> Windows con WSL: los comandos se lanzan con
#              "wsl -d <WSL_DISTRO> -- bash -c ...". REPO_PATH debe darse en
#              notación de Windows (p.ej. C:\Users\...).
#   - False -> Linux nativo, macOS, o estás ejecutando este propio dashboard
#              desde dentro de WSL/Linux: los comandos se lanzan directamente
#              con bash, sin ninguna capa intermedia. REPO_PATH debe darse en
#              notación normal de Linux/macOS (p.ej. /home/usuario/...).
USE_WSL = True

# Solo se usa si USE_WSL = True: distribución de WSL donde está instalado ROS2/Kautham/ktmpb
WSL_DISTRO = "Ubuntu-24.04"

# Ruta absoluta a la raíz de este repositorio, en la notación que le corresponda
# según USE_WSL (ver arriba).
REPO_PATH = r"C:\Users\jabel\Documents\Universidad\6º_Cuatrimestre\RA\RA_Manipulador"

# Ruta absoluta a la raíz del workspace de ROS2 (ws_tamp), en notación Linux
# (la que entiende el bash donde corre ROS2 de verdad, tanto si es WSL como si
# es Linux nativo).
WS_TAMP_PATH = "/home/jabel/Universidad/6C/RA/P4/ws_tamp"

# --- Los siguientes valores normalmente no hace falta tocarlos ---

# Subcarpeta (relativa a WS_TAMP_PATH) donde vive el escenario de Kautham/ktmpb
SCENARIO_SUBPATH = "src/task_and_motion_planning2/ktmpb/ktmpb_demos/OMPL_geometric_demos/chess_ur3_robotiq"

# Nombre del fichero de configuración TAMP que se le pasa a ktmpb
TAMP_CONFIG_FILENAME = "tampconfig_pyramid.xml"

# Carpeta de modelos de Kautham (instalación del sistema). Requiere haber copiado
# antes los ficheros de objects/ ahí manualmente con sudo (ver README.md).
MODELS_FOLDER_PATH = "/usr/share/kautham/demos/models"


def scenario_folder_path() -> str:
    """Ruta absoluta (en el bash donde corre ROS2) a la carpeta del escenario chess_ur3_robotiq."""
    return f"{WS_TAMP_PATH.rstrip('/')}/{SCENARIO_SUBPATH}"

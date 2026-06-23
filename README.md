# RA_Manipulador

Proyecto de planificación de tareas y movimientos (TAMP) para un brazo UR3 con
pinza Robotiq 85, que apila 10 basos formando una pirámide,
usando Kautham y ktmpb sobre ROS2.

## Estructura del repositorio

- `config/` — `tampconfig_pyramid.xml` (configuración TAMP: posiciones iniciales y acciones Pick/Place).
- `problem/` — `OMPL_RRTConnect_pyramid_ur3.xml` (escena y parámetros del planificador OMPL).
- `pddl/` — dominio y problema PDDL de la pirámide.
- `taskfile/` — `taskfile_tampconfig_pyramid.xml`, la solución (trayectorias) que genera ktmpb al resolver el problema.
- `robot/` — `generador_UR_xml.py` (genera `UR3.py` a partir del taskfile), `UR3.py`, y los scripts de pinza `open_grip.py`/`close_grip.py`.
- `objects/` — modelos `.urdf`/`.wrl` de los cilindros usados como piezas en Kautham.
- `posiciones.txt` — orientaciones y posiciones medidas en el robot real; fuente de verdad para recalcular `tampconfig`/`OMPL`.
- `orientaciones_finales_normalizadas.txt` — documentación derivada de las orientaciones finales (Place) ya normalizadas.
- `dashboard/` — script centralizado que encadena los pasos de recálculo, simulación y generación (ver más abajo).
- Cada carpeta principal tiene una subcarpeta `backups/` con versiones anteriores, solo para referencia.

## Dashboard

En vez de ejecutar cada paso por separado, `dashboard/dashboard.py` ofrece un
menú que encadena:

1. Recalcular `tampconfig_pyramid.xml` y `OMPL_RRTConnect_pyramid_ur3.xml` a partir de `posiciones.txt`.
2. Sincronizar esos dos ficheros con la copia que usa Kautham en el workspace de ROS2.
3. Ejecutar la simulación (`colcon build` + `ros2 launch ktmpb_client ...`) para resolver el problema y generar el taskfile.
4. Copiar el taskfile resultante de vuelta al repositorio.
5. Regenerar `robot/UR3.py` a partir del taskfile.
6. Ejecutar los 5 pasos anteriores en orden, de una sola vez.

**La ejecución de `UR3.py` en el robot real queda fuera del dashboard a propósito** y se sigue haciendo a mano por separado.

### Configuración inicial (una vez por ordenador)

Antes de usar el dashboard, cada miembro del grupo debe editar
`dashboard/config.py`:

- `USE_WSL`: `True` si ROS2/Kautham corren en WSL desde Windows. Debe ponerse en `False` si se ejecutan en Linux nativo, macOS, o si se va a
  ejecutar este propio dashboard ya dentro de WSL/Linux (sin pasar por `wsl.exe`).
- `REPO_PATH`: ruta absoluta a la raíz de este repositorio. Si `USE_WSL=True`,
  en notación de Windows (`C:\Users\...`); si `USE_WSL=False`, en notación
  normal de Linux/macOS (`/home/usuario/...`).
- `WS_TAMP_PATH`: ruta absoluta a la raíz del workspace de ROS2 (`ws_tamp`),
  siempre en notación Linux (la que entiende el bash donde corre ROS2 de
  verdad, esté en WSL o no).

El resto de valores del fichero (distribución de WSL, subcarpeta del escenario,
carpeta de modelos de Kautham...) normalmente no hace falta tocarlos salvo que
la instalación de Kautham/ktmpb sea distinta de la habitual.

### Paso manual único: copiar los modelos de los cilindros a Kautham

Kautham busca los modelos de los objetos dentro de su propia carpeta de
instalación (`/usr/share/kautham/demos/models/...`), que pertenece a `root` y
no es accesible para el dashboard sin contraseña (es necesario usar `sudo`). Por eso, **es necesario copiar manualmente, una sola vez (o varias si se hacen cambios en estos modelos fuera de su carpeta), los ficheros
de `objects/` a esa carpeta**, ejecutando en un terminal:

Si usas WSL desde Windows:
```
wsl -d Ubuntu-24.04 -- sudo cp "/mnt/c/ruta/a/su/repo/objects/cupCylinder.urdf" "/mnt/c/ruta/a/su/repo/objects/cupCylinder.wrl" "/mnt/c/ruta/a/su/repo/objects/cupCylinderC10.urdf" "/mnt/c/ruta/a/su/repo/objects/cupCylinderC10.wrl" /usr/share/kautham/demos/models/obstacles/TMP/
```
Sustituya `/mnt/c/ruta/a/tu/repo` por la ruta de su repositorio convertida a
formato WSL (la misma que `REPO_PATH` en `config.py`, con `C:\...` ->
`/mnt/c/...` y las `\` cambiadas por `/`).

Si se está usando Linux nativo, macOS, o ya se está trabajando dentro de WSL/Linux:
```
sudo cp /ruta/a/su/repo/objects/cupCylinder.urdf /ruta/a/su/repo/objects/cupCylinder.wrl /ruta/a/su/repo/objects/cupCylinderC10.urdf /ruta/a/su/repo/objects/cupCylinderC10.wrl /usr/share/kautham/demos/models/obstacles/TMP/
```

### Uso

```
python dashboard/dashboard.py
```

Y escoja la opción del menú que necesite.

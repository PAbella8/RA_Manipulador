import xml.etree.ElementTree as ET

def parse_xml_and_generate_code(xml_file, output_file):
    tree = ET.parse(xml_file)
    root = tree.getroot()

    # Cabecera
    generated_code = [
        "import socket",
        "import time",
        "",
        "# Dirección IP del robot UR",
        "HOST = \"10.10.73.236\"",
        "",
        "# Puerto del servidor en el robot",
        "PORT = 30002",
        "",
        "# Puerto del Dashboard Server, usado para saber si el robot ha terminado de ejecutar un programa",
        "DASHBOARD_PORT = 29999",
        "",
        "# Scripts para abrir y cerrar la pinza",
        "Abrir_pinza = 'open_grip.py'",
        "Cerrar_pinza = 'close_grip.py'",
        "",
        "# Función que espera hasta que el robot termine de ejecutar el programa en curso.",
        "# Primero intenta confirmar que el programa ha empezado (evita una condicion de",
        "# carrera en la que el Dashboard Server todavia reporta el estado \"parado\" del",
        "# programa anterior). Si el programa es muy corto (p.ej. un script de pinza) puede",
        "# terminar antes de que sea detectado, es por esto que esa primera comprobación tiene un timeout:",
        "# si se agota sin recibir \"true\", se asume que el programa ya ha terminado.",
        "def wait_until_done(dash_sock, start_timeout=0.5):",
        "    started = False",
        "    deadline = time.time() + start_timeout",
        "    while time.time() < deadline:",
        "        dash_sock.send(b\"running\\n\")",
        "        response = dash_sock.recv(1024).decode().strip()",
        "        if \"true\" in response.lower():",
        "            started = True",
        "            break",
        "        time.sleep(0.02)",
        "    if not started:",
        "        return  # en caso de que el programa sea demasiado corto para detectar el inicio: ya ha terminado",
        "    while True:",
        "        dash_sock.send(b\"running\\n\")",
        "        response = dash_sock.recv(1024).decode().strip()",
        "        if \"false\" in response.lower():",
        "            break",
        "        time.sleep(0.05)",
        "",
        "# Función para enviar una trayectoria en espacio de configuraciones a la controladora del robot",
        "def send_joint_path(path, sock, dash_sock):",
        "    lines = [\"def move_path():\"]",
        "    for i, joint_config in enumerate(path):",
        "        r = 0.0 if i == len(path) - 1 else 0.01",
        "        lines.append(f\"  movej({joint_config}, a=0.4, v=0.4, r={r})\")",
        "    lines.append(\"end\")",
        "    lines.append(\"move_path()\")",
        "    program = \"\\n\".join(lines) + \"\\n\"",
        "    print(program)",
        "    sock.send(program.encode())",
        "    wait_until_done(dash_sock)  # esperar a que el robot llegue a la posición deseada",
        "",
        "# Conexión via socket a la controladora del robot",
        "sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)",
        "sock.connect((HOST, PORT))",
        "",
        "# Conexión via socket al Dashboard Server del robot",
        "dash_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)",
        "dash_sock.connect((HOST, DASHBOARD_PORT))",
        ""
    ]

    trajectory_counter = 1
    previous_state = None

    for elem in root:
        if elem.tag in ['Transit', 'Transfer']:
            current_state = elem.tag
            
            # Analizar las transiciones para mandar comandos de pinza usando sendall
            if previous_state == 'Transit' and current_state == 'Transfer':
                # Cerrar pinza (Pick)
                generated_code.append("# Enviar archivo script cerrar pinza")
                generated_code.append("with open(Cerrar_pinza, 'rb') as f: sock.sendall(f.read())")
                generated_code.append("time.sleep(1) # Margen de seguridad")
                generated_code.append("")

            elif previous_state == 'Transfer' and current_state == 'Transit':
                # Abrir pinza (Place)
                generated_code.append("# Enviar archivo script abrir pinza")
                generated_code.append("with open(Abrir_pinza, 'rb') as f: sock.sendall(f.read())")
                generated_code.append("time.sleep(1) # Margen de seguridad")
                generated_code.append("")
            
            # Extraer los datos de la trayectoria actual
            points = []
            for conf in elem.findall('Conf'):
                values = [float(v) for v in conf.text.strip().split()]
                ur3_joints = values[9:15]  # Coger solo del 10º al 15º
                points.append(ur3_joints)
            
            # Crear la variable "path_x" y enviarla
            traj_name = f"path_{trajectory_counter}"
            generated_code.append(f"# Trayectoria {trajectory_counter}")
            generated_code.append(f"{traj_name} = [")
            for pt in points:
                generated_code.append(f"    {pt},")
            generated_code.append("]")
            generated_code.append("")
            
            generated_code.append("# Se envia la trayectoria a la controladora del robot")
            generated_code.append(f"send_joint_path({traj_name}, sock, dash_sock)")
            generated_code.append("")

            previous_state = current_state
            trajectory_counter += 1

    generated_code.append("# Mensaje que se imprime cuando se finaliza la ejecución")
    generated_code.append("# de la trayectoria")
    generated_code.append("print(\"Trayectoria finalizada\")")
    generated_code.append("")
    generated_code.append("data = sock.recv(1024)")
    generated_code.append("")
    generated_code.append("# Se cierra la conexión")
    generated_code.append("sock.close()")
    generated_code.append("dash_sock.close()")
    generated_code.append("")

    # Guardar archivo
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(generated_code))
    
    print(f"¡Hecho! El archivo {output_file} ha sido generado con el nuevo formato.")

if __name__ == '__main__':
    parse_xml_and_generate_code('../taskfile/taskfile_tampconfig_pyramid.xml', 'UR3.py')

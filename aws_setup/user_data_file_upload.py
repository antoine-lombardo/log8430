def file_upload_commands(local_file: str, remote_file: str):
    commands = ''
    lines = None
    with open(local_file, "r") as file:
        lines = file.readlines()
    for i in range(len(lines)):
        lines[i] = lines[i].replace('\\', '\\\\\\\\').replace('"', '\\"').replace('$', '\\$').replace('`', '\\`')
    one_line = ''.join(lines)
    commands +=  'printf "{}" > {}'.format(one_line, remote_file)
    commands += '\n\nchmod 777 {}\nchmod +x {}\n\n\n'.format(remote_file, remote_file)
    return commands
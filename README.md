# Dev-container for docker and iobroker

The goal of the devcontainer is to create an encapsulated container for adapter development with iobroker. One adapter or multiple adapters can be developed in parallel within the container.

## dockerfile

A Bullseye node 20 image is used as the base image. Other base images can be used. See the tag list at <https://hub.docker.com/_/node>.

In the Dockerfile, an openssh server is first installed and a user named dev is created in the dev group.

The ssh daemon has been configured so that it is also possible to log in with an (empty) password. For security reasons, this can be changed to "no" in each case.

Node's global package directory is placed in the user directory of dev.

Furthermore, various other directories are created in the user directory so that they remain as volumes even after the container is regenerated and can be mounted on the developer's hard drive:

- sshfiles: Storage location for the authorized_keys file, which contains the public key of the development computer from which you want to connect to the dev container.
- projects: Root directory for all project directories and repositories
- .vscode-server: vscode server in the container, which maintains contact with the vscode instance of the development computer.

> **Anmerkung**
>
> Theoretically, the setup should also work with an LXC container or VM in a similar configuration. This cannot currently be tested.
>
> Feedback is appreciated

## entrypoint.sh

In the start script entrypoint.sh, which is executed every time the container is started, the ssh key file is copied to the correct location and the ssh server is started.

## Creating the Docker Image

Save the content of this repoistory in a directory of your choice.

Run the following command in the Dockerfile directory.
Please note the period at the end of the command.
The -t option allows you to assign a name to the image, which can then be used to reference it in docker-compose.

```bash
sudo docker build -t iobdevcontainer:20-bullseye .
```

## docker compose example

| parameter       | description                                                                                                                          |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| image           | Name of the image, use the tag-name of the image                                                                                     |
| iobdevcontainer | docker compose service name / container name                                                                                         |
| hostname        | nice hostname to optional access the container in browser. you have to map this name to the ip-address in your dns and reverse-proxy |
| ports           | mapped ports: ssh 22 is mapped to 2222 to avoid conflicts, 8081/8082 for admin and vis. add more mappings if needed                  |
| volumes         | mapped volumes: sshfiles (mandatory), projects (recommended), npm-global (optional), vscode-server (optional)                        |

```yaml
version: "3"
services:
  iobdevcontainer:
    image: iobdevcontainer:20-bullseye
    hostname: devcontainer
    restart: unless-stopped
    ports:
      - "2222:22"
      - "8081:8081"
      - "8082:8082"
    volumes:
      - /<localpath>/devcontainer/ssh:/home/dev/sshfiles
      - /<localpath>/devcontainer/projects:/home/dev/projects
      - /<localpath>/devcontainer/npm-global:/home/dev/.npm-global
      - /<localpath>/devcontainer/vscode-server:/home/dev/.vscode-server
```

## setup ssh keys

Run the following command on the command line to generate a private and public key:

```bash
ssh-keygen
```

After that, the files are located in the directory C:\Users\.ssh\ (windows) or /home/user/.ssh (Linux)

- id_rsa
- id_rsa.pub

The public key can then be copied to a remote computer or into the mapped directory sshfile in the file authorized_keys (example is shortened).

```bash
ssh-rsa AAAAB3NzaC...iSvEKQ== user@computer
```

## Connect vscode to the devcontainer

- Install the Extension "[Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)" in vscode
- Configure the Connection: \<CTRL\>+\<Shift+P\> Remote-SSH: Add New SSH Host
- Enter the connection address of the remote container, e.g. dev@\<IP\>
- If the ssh port has been mapped to another one like 22, you should add :\<port\> here
- Please check the generated configuration file to ensure that the values ​​HostName, Port and User correspond to the correct values, according to the following scheme:

```bash
Host 192.168.1.123:2222
  HostName 192.168.1.123
  Port 2222
  User dev
```

- Start the connection with \<CTRL\>+\<Shift+P\> Remote-SSH: Connect to Host
- Once the connection is successful, you can then select the appropriate folder and execute all commands remotely via the terminal.
- A typical next action would be either cloning a github repository or creating and initializing a new repository below the projects directory.

## Debugging

### Common for all debugging variants

- dev-server setup according to the documentation
- start the dev-server in watch mode without the adapter with the following command
- vscode map automaticly the port 8081 to your local machine and you can open iobroker in your browser with the following link http://127.0.0.1:8081

```bash
dev-server watch --noStart
```

### Debug JS Adapters

- launch the adapter with the following launch configuration via menu/run/start debugging or F5. To test the debugging the option "stopOnEntry" is set to true

```json
        {
            "type": "node",
            "request": "launch",
            "name": "default Launch ioBroker Adapter ",
            "skipFiles": ["<node_internals>/**"],
            "args": ["--debug", "0"],
            "program": "node_modules/iobroker.<adaptername>/main.js",
            "cwd": "${workspaceFolder}/.dev-server/default",
            "stopOnEntry": true,
            "sourceMaps": true,
            "console": "internalConsole",
            "outputCapture": "std",
            "resolveSourceMapLocations": ["${workspaceFolder}/**", "**/node_modules/**"]
        },
```

- the process should stop at the first line of the adapter and the debugging can be started.
- if you change the adapter code, simply restart the debugging process.

### Debug admin JSONconfig

todo

### Debug admin JSONconfig with custom react components

todo

### Debug admin materialize

todo

### Debug tab materialize

todo

### Debug tab react

todo

### Debug JS Widgets in vis

- launch vis with the following launch configuration via menu/run/start debugging or F5.
- if vscode didnt automatically recognize the port 8082, you have to map it manually in the port view of vscode
- if vis isnt installed in iobroker you have to add it via the gui

```json
        {
            "type": "chrome",
            "request": "launch",
            "name": "vis edit",
            "url": "http://127.0.0.1:8082/vis/edit.html#test",
            "webRoot": "${workspaceFolder}",
            "trace": true,
            "skipFiles": ["socket.io.js"]
        },
```

### Debug JS React Widgets in vis-2

todo

 Entorno de desarrollo

## Windows con XAMPP

Esta guía deja ChuspaSocial funcionando en Windows con XAMPP y Moodle 4.5 LTS,
con los cambios de `src/` reflejados al instante en Moodle.
Fue probada con XAMPP (PHP 8.2.12), MariaDB 10.11.19 y Moodle 4.5.15.

### Requisitos

- Windows 10 u 11.
- [XAMPP](https://www.apachefriends.org/) con **PHP 8.1, 8.2 u 8.3**.
- **MariaDB 10.6.7 o superior** (o MySQL 8.0+), requisito de Moodle 4.5.
- [Git para Windows](https://git-scm.com/download/win).
- Tu fork de este repositorio clonado en tu equipo (en adelante, `<RUTA_REPO>`).

Comprueba las versiones que trae tu XAMPP:

```powershell
C:\xampp\php\php.exe --version
C:\xampp\mysql\bin\mysql.exe --version
```

Si MariaDB es anterior a 10.6.7 (por ejemplo, 10.4.x), sigue la
[actualización de MariaDB](#actualizar-mariadb-si-tu-xampp-trae-una-versión-anterior-a-1067)
antes de continuar.

### 1. Configurar PHP

1. Abre `C:\xampp\php\php.ini` y verifica que estas extensiones estén activas
   (sin `;` al inicio): `intl`, `zip`, `gd`, `soap`, `sodium` y `mysqli`.
2. Busca la línea `;max_input_vars = 1000` y déjala **sin `;`** y con este valor:

```ini
   max_input_vars = 5000
```

3. Guarda el archivo y reinicia **Apache** desde el XAMPP Control Panel.
4. Comprueba que PHP lee el valor nuevo:

```powershell
   C:\xampp\php\php.exe -r "echo ini_get('max_input_vars');"
```

   Debe responder `5000`.

### 2. Iniciar la base de datos y crearla

1. En el XAMPP Control Panel, inicia **Apache** y **MySQL**.
2. Comprueba que MariaDB responde en el puerto 3306:

```powershell
   C:\xampp\mysql\bin\mysql.exe -u root -e "SELECT VERSION();"
```

3. Crea la base de datos de Moodle:

```powershell
   C:\xampp\mysql\bin\mysql.exe -u root -e "CREATE DATABASE moodle CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

### 3. Clonar Moodle 4.5

```powershell
cd C:\xampp\htdocs
git clone --branch MOODLE_405_STABLE --depth 1 https://github.com/moodle/moodle.git moodle
mkdir C:\xampp\moodledata
```

La carpeta `moodledata` debe quedar **fuera** de `htdocs`.

### 4. Enlazar el plugin en `local/chuspasocial`

Crea un enlace (junction) desde la carpeta `src/` de tu repositorio.
Este paso debe hacerse **antes** de instalar Moodle.

```powershell
New-Item -ItemType Junction `
  -Path C:\xampp\htdocs\moodle\local\chuspasocial `
  -Target <RUTA_REPO>\src
```

Comprueba el enlace:

```powershell
Test-Path C:\xampp\htdocs\moodle\local\chuspasocial\version.php
```

Debe responder `True`. Si `New-Item` da error de permisos, abre PowerShell como administrador.

### 5. Instalar Moodle

```powershell
cd C:\xampp\htdocs\moodle
C:\xampp\php\php.exe admin\cli\install.php `
  --wwwroot=http://localhost/moodle `
  --dataroot=C:\xampp\moodledata `
  --dbtype=mariadb --dbhost=127.0.0.1 --dbname=moodle `
  --dbuser=root --dbpass= `
  --fullname='ChuspaSocial Dev' --shortname=chuspa `
  --adminuser=admin --adminpass='<CONTRASEÑA>' `
  --adminemail=admin@example.com `
  --agree-license --non-interactive
```

- La contraseña debe cumplir la política de Moodle: mínimo 8 caracteres,
  con mayúscula, minúscula, número y un símbolo.
- Tarda varios minutos. No lo interrumpas hasta ver `Installation completed successfully.`
- Las advertencias de `openssl_pkey_export` del módulo LTI son normales en XAMPP
  y no impiden la instalación.

### 6. Verificar la instalación

1. Comprueba que se creó la tabla del plugin:

```powershell
   C:\xampp\mysql\bin\mysql.exe -u root -e "SHOW TABLES FROM moodle LIKE 'mdl_local_chuspasocial%';"
```

2. Abre `http://localhost/moodle` e inicia sesión con el usuario `admin`.
3. Ve a **Administración del sitio > Extensiones > Resumen de extensiones**
   y busca `local_chuspasocial`. Debe aparecer instalado.

### Actualizar MariaDB si tu XAMPP trae una versión anterior a 10.6.7

1. Descarga el **ZIP** (no el MSI) de MariaDB 10.11 LTS para Windows desde
   [mariadb.org/download](https://mariadb.org/download/).
   En **Package Type** elige `ZIP file`, no `ZIP file (debug symbols only)`.
2. En el XAMPP Control Panel, detén MySQL.
3. Aparta la carpeta vieja y coloca la nueva:

```powershell
   Rename-Item C:\xampp\mysql C:\xampp\mysql_old
   Expand-Archive "$HOME\Downloads\mariadb-10.11.*-winx64.zip" C:\xampp\
   Rename-Item (Get-Item C:\xampp\mariadb-10.11.*) mysql
   Copy-Item C:\xampp\mysql_old\bin\my.ini C:\xampp\mysql\bin\my.ini
```

4. Inicia MySQL desde el panel y comprueba la versión:

```powershell
   C:\xampp\mysql\bin\mysql.exe --version
```

La base de datos nueva empieza vacía y el usuario `root` queda sin contraseña.
Para volver atrás, detén MySQL, elimina `C:\xampp\mysql` y renombra `mysql_old` a `mysql`.

### Problemas frecuentes

| Síntoma | Causa probable | Solución |
| --- | --- | --- |
| El instalador pide una versión mayor de MariaDB | XAMPP trae una MariaDB antigua | Seguir la sección de actualización de MariaDB |
| `ERROR 2002 Can't connect to server` | MySQL está detenido en el panel | Iniciar MySQL desde el XAMPP Control Panel |
| `max_input_vars` sigue en 1000 | La línea sigue comentada con `;` | Quitar el `;` en `php.ini` y reiniciar Apache |
| Falta una extensión de PHP (`intl`, `zip`, etc.) | Está comentada en `php.ini` | Quitar el `;` y reiniciar Apache |
| `New-Item` da error de permisos | Faltan privilegios | Abrir PowerShell como administrador |
| El plugin no aparece en Extensiones | El enlace apunta a otra carpeta | Comprobar que `local\chuspasocial\version.php` existe |
| La instalación falla a medias | Error en el código del plugin | Corregirlo y reinstalar (ver abajo) |

### Reinstalar desde cero

Si la instalación falla, vacía la base de datos y los archivos antes de repetirla:

```powershell
C:\xampp\mysql\bin\mysql.exe -u root -e "DROP DATABASE moodle; CREATE DATABASE moodle CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
Remove-Item C:\xampp\htdocs\moodle\config.php -ErrorAction SilentlyContinue
Remove-Item C:\xampp\moodledata\* -Recurse -Force
```

Después vuelve a ejecutar el paso 5.

### Instalación sin enlace (solo para probar)

Si solo quieres probar el plugin sin desarrollar, instálalo desde un zip.
Los pasos están en [`src/README.md`](../src/README.md).

## Linux (Ubuntu)

Esta sección está escrita para **Ubuntu 24.04 LTS** (también sirve en WSL con Ubuntu 24.04). Usa las siguientes versiones:

| Componente | Versión |
|------------|---------|
| Ubuntu     | 24.04 LTS |
| PHP        | 8.3 (Moodle 4.5 soporta de 8.1 a 8.3) |
| MariaDB    | 10.11 |
| Moodle     | 4.5 (`MOODLE_405_STABLE`) |

> Todos los comandos se ejecutan en una terminal de Ubuntu. Reemplaza `/ruta/al/repo` por la ruta donde clonaste este repositorio, por ejemplo `~/proyectos/chuspasocial`.

> **WSL:** instala Ubuntu 24.04 con `wsl --install -d Ubuntu-24.04` y entra con `wsl -d Ubuntu-24.04`. No uses `Ubuntu` a secas: instala la última versión (26.04), que trae PHP 8.5, no soportado por Moodle 4.5. Si tu repositorio está en el disco de Windows, la ruta es `/mnt/c/Users/TU_USUARIO/...`.

### 1. Instalar PHP y sus extensiones (Ubuntu)

```bash
sudo apt update
sudo apt install -y git unzip php php-cli php-curl php-gd php-intl \
  php-mbstring php-xml php-zip php-soap php-mysql
```

Comprueba la versión instalada:

```bash
php -v
```

Debe mostrar PHP 8.3.x.

Moodle exige que `max_input_vars` sea al menos 5000. Configúralo en el `php.ini` de CLI (el que usa el servidor integrado de PHP):

```bash
sudo sed -i 's/^;\?\s*max_input_vars\s*=.*/max_input_vars = 5000/' /etc/php/8.3/cli/php.ini
```

Verifica que el cambio se aplicó:

```bash
php -i | grep max_input_vars
```

Debe mostrar `max_input_vars => 5000 => 5000`.

### 2. Instalar y configurar la base de datos (Ubuntu)

Instala MariaDB y asegúrate de que el servicio esté activo:

```bash
sudo apt install -y mariadb-server
sudo systemctl enable --now mariadb
```

> En WSL sin systemd, si aparece el error `System has not been booted with systemd`, inicia el servicio con `sudo service mariadb start`.

Entra a la consola de MariaDB:

```bash
sudo mariadb
```

Crea la base de datos y el usuario de Moodle (cambia la contraseña por una propia):

```sql
CREATE DATABASE moodle DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'moodleuser'@'localhost' IDENTIFIED BY 'cambia_esta_clave';
GRANT ALL PRIVILEGES ON moodle.* TO 'moodleuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

Comprueba que el usuario puede conectarse:

```bash
mariadb -u moodleuser -p moodle -e "SELECT 1;"
```

Debe pedir la contraseña y mostrar una tabla con un `1`.

### 3. Clonar Moodle 4.5 (Ubuntu)

Clona solo la rama estable 4.5 (sin historial completo, para que sea más rápido):

```bash
cd ~
git clone --depth 1 -b MOODLE_405_STABLE https://github.com/moodle/moodle.git
```

Crea la carpeta de datos de Moodle (`moodledata`), que debe estar **fuera** del directorio de Moodle:

```bash
mkdir -p ~/moodledata
chmod 770 ~/moodledata
```

### 4. Enlazar el plugin en `local/chuspasocial` (Ubuntu)

Crea el enlace simbólico desde Moodle hacia el código del plugin:

```bash
ln -s /ruta/al/repo/src ~/moodle/local/chuspasocial
```

Comprueba que el enlace apunta al lugar correcto:

```bash
ls -l ~/moodle/local/chuspasocial
```

La salida debe mostrar `chuspasocial -> /ruta/al/repo/src`. Además, `src/` debe contener el archivo `version.php` en su raíz, porque Moodle lo usa para reconocer el plugin:

```bash
ls ~/moodle/local/chuspasocial/version.php
```

### 5. Instalar Moodle (Ubuntu)

Ejecuta el instalador por línea de comandos desde la carpeta de Moodle. Como el enlace del paso anterior ya existe, el plugin se instala junto con Moodle.

```bash
cd ~/moodle
php admin/cli/install.php \
  --lang=es \
  --wwwroot=http://localhost:8000 \
  --dataroot="$HOME/moodledata" \
  --dbtype=mariadb \
  --dbhost=localhost \
  --dbname=moodle \
  --dbuser=moodleuser \
  --dbpass='cambia_esta_clave' \
  --fullname="Moodle Dev" \
  --shortname="dev" \
  --adminuser=admin \
  --adminpass='Admin123!' \
  --agree-license \
  --non-interactive
```

Al terminar se crea el archivo `~/moodle/config.php`. Los datos de acceso del administrador son los que indicaste en `--adminuser` y `--adminpass`.

### 6. Levantar el servidor y verificar (Ubuntu)

Inicia el servidor integrado de PHP desde la carpeta de Moodle:

```bash
cd ~/moodle
php -S localhost:8000
```

Abre <http://localhost:8000> en el navegador e inicia sesión con el usuario administrador. Luego verifica que el plugin quedó instalado en **Administración del sitio > Plugins > Resumen de plugins** (busca `chuspasocial`).

Para detener el servidor, presiona `Ctrl + C` en la terminal.

### Actualizar el plugin después de cambios (Ubuntu)

Si modificas el archivo `version.php` o agregas cambios de base de datos en `src/`, aplica la actualización con:

```bash
cd ~/moodle
php admin/cli/upgrade.php --non-interactive
```

### Problemas frecuentes en Ubuntu

**`Fatal error: Class "..." not found` o extensión faltante.** Falta una extensión de PHP. Revisa el paso 1 y vuelve a ejecutar el `apt install`.

**`Database connection failed`.** Verifica usuario, contraseña y nombre de la base de datos con el comando de prueba del paso 2.

**`The moodledata directory is not writable`.** Asegura que tu usuario es dueño de la carpeta y tiene permisos de escritura:

```bash
sudo chown -R "$USER":"$USER" ~/moodledata
chmod 770 ~/moodledata
```

**El plugin no aparece en Moodle.** Comprueba que el enlace simbólico apunta a `src/` (paso 4) y que `version.php` está en la raíz de `src/`.

**La instalación falla a medias con un error de sintaxis (`ParseError`).** Hay un error en el código del plugin. Actualiza tu rama con los últimos cambios de `dev`, o corrige el archivo que indica el error, y reinstala desde cero (ver abajo).

**El puerto 8000 está ocupado.** Usa otro puerto, por ejemplo 8080, y cambia también `--wwwroot` (o `$CFG->wwwroot` en `~/moodle/config.php`) para que coincida.

### Reinstalar desde cero en Ubuntu

Si necesitas repetir la instalación, elimina la base de datos, los datos de Moodle y el `config.php`, y vuelve al paso 5:

```bash
sudo mariadb -e "DROP DATABASE moodle;"
sudo mariadb -e "CREATE DATABASE moodle DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
rm -rf ~/moodledata/*
rm ~/moodle/config.php
```

## Problemas comunes

### Error `max_input_vars`

**Síntoma**

Durante la instalación o comprobación del entorno, Moodle muestra el mensaje:

`PHP setting max_input_vars must be at least 5000.`

**Causa**

La directiva `max_input_vars` de PHP está configurada con un valor menor que `5000`. Moodle necesita al menos ese límite para procesar correctamente formularios con una gran cantidad de campos.

**Solución**

1. Localiza el archivo `php.ini` utilizado por el servidor web.
2. Busca la directiva `max_input_vars` y establece:

   ```ini
   max_input_vars = 5000
   ```

3. Guarda el archivo y reinicia el servicio web o PHP para aplicar el cambio.
4. Verifica el valor activo con:

   ```bash
   php -i | grep max_input_vars
   ```

El valor efectivo debe ser `5000` o superior.

### Error de extensiones de PHP faltantes

#### Síntoma

Al ejecutar un comando de Composer (por ejemplo `composer install` o `composer diagnose`) aparece el mensaje:

```text
In Factory.php line 656:

  The openssl extension is required for SSL/TLS protection but is not available. If you can not enable the openssl extension, you can disable this error, at your own risk, by setting the 'disable-tls' option to true.
```

El mensaje cambia según la extensión que falte, pero siempre indica su nombre.

#### Causa

La extensión de PHP requerida no está instalada o está comentada (con `;` al inicio) en el archivo `php.ini`.

#### Cómo detectarlas

1. Lista las extensiones cargadas:

   ```bash
   php -m
   ```

2. Busca una en concreto:

   ```bash
   php -m | grep -i openssl
   ```

   En Windows (CMD) usa `php -m | findstr /i openssl`.

3. Comprueba qué extensiones exige el proyecto:

   ```bash
   composer check-platform-reqs
   ```

Si la extensión no aparece en la lista, está deshabilitada o no instalada.

#### Solución

1. Localiza el `php.ini` que usa PHP:

   ```bash
   php --ini
   ```

2. Ábrelo y quita el `;` del inicio de la línea de la extensión:

   ```ini
   extension=openssl
   ```

3. Guarda el archivo y abre una terminal nueva para aplicar el cambio.
4. Verifica que ya aparece con `php -m`.

En Linux, si la extensión no está instalada, instálala con el gestor de paquetes (por ejemplo `sudo apt install php-mbstring`).
### Error `dataroot not writable`

#### Síntoma

Durante la instalación o al abrir Moodle, aparece el mensaje:

`Fatal error: $CFG->dataroot is not writable, admin has to fix directory permissions! Exiting.`

#### Causa

Moodle no puede escribir en la carpeta `moodledata`. Puede ocurrir porque la carpeta no existe, porque la ruta indicada en `--dataroot` (o en `$CFG->dataroot` de `config.php`) es incorrecta, o porque el usuario con el que corre Apache no tiene permisos de escritura sobre ella.

#### Solución

#### En Windows

1. Comprueba que la carpeta existe y que la ruta coincide con la de `config.php`:

   ```powershell
   Test-Path C:\xampp\moodledata
   ```

   Si responde `False`, créala con `mkdir C:\xampp\moodledata`.

2. Haz clic derecho en `C:\xampp\moodledata` > **Propiedades** > **Seguridad** > **Editar**.
3. Selecciona el grupo `Users` (o el usuario con el que corre Apache) y marca **Modificar**.
4. Aplica los cambios y reinicia **Apache** desde el XAMPP Control Panel.
5. Verifica el permiso. Debe aparecer `Modify` o `FullControl`:

   ```powershell
   icacls C:\xampp\moodledata
   ```

#### En Linux

1. Crea la carpeta si no existe y asigna el usuario del servidor web (`www-data` en Debian/Ubuntu, `apache` en Fedora/RHEL):

   ```bash
   sudo mkdir -p /var/www/moodledata
   sudo chown -R www-data:www-data /var/www/moodledata
   sudo chmod -R 775 /var/www/moodledata
   ```

2. Reinicia el servidor web (por ejemplo, `sudo systemctl restart apache2`).

#### En macOS

1. Crea la carpeta y da permisos al usuario del servidor web (`_www` con el Apache del sistema; con XAMPP o MAMP suele ser `daemon`):

   ```bash
   sudo mkdir -p /usr/local/moodledata
   sudo chown -R _www:_www /usr/local/moodledata
   sudo chmod -R 775 /usr/local/moodledata
   ```

2. Reinicia Apache.

La carpeta `moodledata` debe estar **fuera** de `htdocs`.

# SIN LEYES RP 2.0 - NX-Core v0.2

## Instalacion txAdmin
1. Publica `recipe.yaml` como archivo RAW accesible por HTTPS (por ejemplo en un repositorio GitHub propio).
2. En txAdmin crea servidor con **Remote URL Template** y pega la URL RAW. No sirve subir un ZIP como URL.
3. Completa credenciales MySQL, licencia y datos de txAdmin. La receta importa las tablas en la base seleccionada.
4. Revisa los logs de instalacion y arranque.

## Instalacion manual
1. Copia `resources/nx-core` al directorio resources de FXServer.
2. Instala oxmysql y los recursos basicos de FiveM.
3. Importa `database/install.sql` en tu base existente.
4. Adapta `server.cfg` sustituyendo los placeholders de txAdmin por valores reales.

## Alcance y advertencias
Es un MVP de nucleo: registro por licencia, spawn, saldos, posicion y exportaciones basicas. No contiene multicharacter, inventario, trabajos avanzados, policia ni HUD. No se ha ejecutado dentro de FXServer ni se ha verificado la descarga de dependencias en vivo.

## Nota oxmysql
La receta descarga el repositorio fuente de oxmysql. Segun la revision del repositorio, puede requerirse la distribucion compilada de Releases para contar con archivos JS listos para ejecutar. Si falla el arranque, instala la release distribuida de oxmysql en `resources/oxmysql`.

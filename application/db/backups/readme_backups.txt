Per a que s'executin els backups s'ha de posar una línia com
la següent al crontab (/etc/crontab):

1 8 * * * root ruby path_al_script_backup.rb

I potser s'ha d'alterar l'script backup.rb per posar-hi l'usuari/password correctes
al mysqldump.

# Mail_log

## Пояснения к решению

Предварительные условия:
Установленная база mysql, с созданной базой и таблицами. SQL запрос по созданию базы и таблиц можно найти в `/data/sql/mail_log.sql`
Настроенный конфиг `/conf/mysql_connect.conf` для подключения к базе 

### Задание №1
Для разбора файла с логами необходимо вызвать:
```
perl ./util/log_parser.pl
```
В результате работы будут добавлены записи в базу.

### Задание №2
Необходимые зависимости установить как показано ниже:
```
cpan install Plack::App::CGIBin
cpan install CGI::Compile
cpan install CGI::Emulate::PSGI
```
При необходимости поменять ip с localhost на нужный в файле `./data/templates/plack_cgi.pl`
Запустить эмулятор командой `plackup ./bin/plack_cgi.pl`
Адрес приложения: `http://localhost:5000/cgi/searcher.pl`. Переходим по ссылке и наслаждаемся ^-^

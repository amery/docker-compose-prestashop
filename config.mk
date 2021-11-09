TRAEFIK_BRIDGE ?= traefiknet
NAME ?= prestashop
HOSTNAME ?= $(NAME).docker.localhost
MYSQL_SERVER ?= mysql
MYSQL_IMAGE ?= mysql:5
MYSQL_DATABASE ?= $(NAME)
MYSQL_USER ?= $(MYSQL_DATABASE)
MYSQL_PASSWORD ?= prestashop
MYSQL_ROOT_PASSWORD ?= $(MYSQL_PASSWORD)
PS_DISABLE_MAKE ?= 0
PS_INSTALL_AUTO ?= 1
PS_FOLDER_INSTALL ?= install-dev
PS_FOLDER_ADMIN ?= admin-dev

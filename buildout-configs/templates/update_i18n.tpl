#!/bin/bash

DOMAIN=default
I18NDUDE_NAME=i18ndude
I18NDUDE_PATH=${parts.buildout.directory}/bin
P_NAMESPACE=Products
P_NAME=Reportek
PRODUCT=$$P_NAMESPACE.$$P_NAME
PRODUCT_SRC=${parts.buildout.directory}/src/$$PRODUCT
LOCALE_DIR=$$PRODUCT_SRC/$$P_NAMESPACE/$$P_NAME/locales

[ -n "$1" ] && I18NDUDE_PATH="$1"

cd $$LOCALE_DIR
$$I18NDUDE_PATH/$$I18NDUDE_NAME rebuild-pot --pot $$DOMAIN.pot --create $$DOMAIN $$PRODUCT_SRC
$$I18NDUDE_PATH/$$I18NDUDE_NAME sync --pot $$DOMAIN.pot */LC_MESSAGES/$$DOMAIN.po

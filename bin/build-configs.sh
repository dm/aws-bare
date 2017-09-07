#!/bin/bash

cd config/
perl -p -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg; s/\$\{([^}]+)\}//eg' config.dev.json.tpl > config.dev.json
perl -p -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg; s/\$\{([^}]+)\}//eg' config.stg.json.tpl > config.stg.json
perl -p -e 's/\$\{([^}]+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg; s/\$\{([^}]+)\}//eg' config.prd.json.tpl > config.prd.json
zip "${PROJECT}-${NAME_SUFFIX}-foundation.zip" config*.json

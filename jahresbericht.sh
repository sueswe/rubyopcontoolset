#!/bin/bash

echo "Erstellung Zwischenbericht/Jahresbericht"
von=$1
bis=$2
if [[ -z ${von} || -z ${bis} ]];then
    echo "Usage: $0 yyyy-mm-dd yyyy-mm-dd"
    exit 1
fi

rm *.html

echo "Erzeuge Markdown für prod ..."
odbc/jahresbericht.rb -d prod -v ${von} -b ${bis} > produktion.md
rtc=$? ; if [[ "$rtc" -ne 0 ]]; then { exit $rtc ; } else { echo "  done." ; } fi

echo "Erzeuge Markdown für test ..."
odbc/jahresbericht.rb -d test -v ${von} -b ${bis} > test.md
rtc=$? ; if [[ "$rtc" -ne 0 ]]; then { exit $rtc ; } else { echo "  done." ; } fi

echo "Erzeuge Markdown für entw ..."
odbc/jahresbericht.rb -d entw -v ${von} -b ${bis} > entwicklung.md
rtc=$? ; if [[ "$rtc" -ne 0 ]]; then { exit $rtc ; } else { echo "  done." ; } fi

for md in $(ls *.md); do
    echo "Erzeuge HTML ..."
    html=${md%.md}
    kramdown ${md} > ${html}.html
    rtc=$? ; if [[ "$rtc" -ne 0 ]]; then { exit $rtc ; } else { echo "  done." ; } fi
    rm ${md}
done

exit 0

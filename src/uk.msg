namespace eval ::tcl::clock {
    ::msgcat::mcset uk DAYS_OF_WEEK_ABBREV [list \
        "\u041D\u0434" \
        "\u041F\u043D" \
        "\u0412\u0442" \
        "\u0421\u0440" \
        "\u0427\u0442" \
        "\u041F\u0442" \
        "\u0421\u0431"]
    ::msgcat::mcset uk DAYS_OF_WEEK_FULL [list \
        "\u041D\u0435\u0434\u0456\u043B\u044F" \
        "\u041F\u043E\u043D\u0435\u0434\u0456\u043B\u043E\u043A" \
        "\u0412\u0456\u0432\u0442\u043E\u0440\u043E\u043A" \
        "\u0421\u0435\u0440\u0435\u0434\u0430" \
        "\u0427\u0435\u0442\u0432\u0435\u0440" \
        "\u041F\u2019\u044F\u0442\u043D\u0438\u0446\u044F" \
        "\u0421\u0443\u0431\u043E\u0442\u0430"]
    ::msgcat::mcset uk MONTHS_ABBREV [list \
        "\u0421\u0456\u0447" \
        "\u041B\u044E\u0442" \
        "\u0411\u0435\u0440" \
        "\u041A\u0432\u0456" \
        "\u0422\u0440\u0430" \
        "\u0427\u0435\u0440" \
        "\u041B\u0438\u043F" \
        "\u0421\u0435\u0440" \
        "\u0412\u0435\u0440" \
        "\u0416\u043E\u0432" \
        "\u041B\u0438\u0441" \
        "\u0413\u0440\u0443" \
        ""]
    ::msgcat::mcset uk MONTHS_FULL [list \
        "\u0421\u0456\u0447\u0435\u043D\u044C" \
        "\u041B\u044E\u0442\u0438\u0439" \
        "\u0411\u0435\u0440\u0435\u0437\u0435\u043D\u044C" \
        "\u041A\u0432\u0456\u0442\u0435\u043D\u044C" \
        "\u0422\u0440\u0430\u0432\u0435\u043D\u044C" \
        "\u0427\u0435\u0440\u0432\u0435\u043D\u044C" \
        "\u041B\u0438\u043F\u0435\u043D\u044C" \
        "\u0421\u0435\u0440\u043F\u0435\u043D\u044C" \
        "\u0412\u0435\u0440\u0435\u0441\u0435\u043D\u044C" \
        "\u0416\u043E\u0432\u0442\u0435\u043D\u044C" \
        "\u041B\u0438\u0441\u0442\u043E\u043F\u0430\u0434" \
        "\u0413\u0440\u0443\u0434\u0435\u043D\u044C" \
        ""]
    ::msgcat::mcset uk BCE "\u0434\u043e \u043d.\u0435."
    ::msgcat::mcset uk CE "\u043f\u0456\u0441\u043b\u044f \u043d.\u0435."
    ::msgcat::mcset uk DATE_FORMAT "%d.%m.%Y"
    ::msgcat::mcset uk TIME_FORMAT "%k:%M:%S"
    ::msgcat::mcset uk DATE_TIME_FORMAT "%d.%m.%Y %k:%M:%S %z"
}

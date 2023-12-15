local Translations = {
    error = {
        negative = 'Zkoušíte prodat záporné množství?',
        no_melt = 'Nedal jste mi nic k rozpuštění...',
        no_items = 'Nedostatek položek',
    },
    success = {
        sold = 'Prodali jste %{value} x %{value2} za $%{value3}',
        items_received = 'Obdrželi jste %{value} x %{value2}',
    },
    info = {
        title = 'Zastavárna',
        subject = 'Rozpouštění položek',
        message = 'Dokončili jsme rozpuštění vašich položek. Můžete si je přijít kdykoliv vyzvednout.',
        open_pawn = 'Otevřít zastavárnu',
        sell = 'Prodat položky',
        sell_pawn = 'Prodat položky zastavárně',
        melt = 'Rozpustit položky',
        melt_pawn = 'Otevřít místo pro rozpouštění',
        melt_pickup = 'Vyzvednout rozpuštěné položky',
        pawn_closed = 'Zastavárna je zavřená. Přijďte zpět mezi %{value}:00 dopoledne a %{value2}:00 odpoledne',
        sell_items = 'Prodejní cena $%{value}',
        back = '⬅ Zpět',
        melt_item = 'Rozpustit %{value}',
        max = 'Maximální množství %{value}',
        submit = 'Rozpustit',
        melt_wait = 'Dejte mi %{value} minut a vaše věci budou rozpuštěny',
    }
}

if GetConvar('qb_locale', 'en') == 'cs' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
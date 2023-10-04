fx_version 'cerulean'
game 'gta5'

description 'QBX-Pawnshop'
repository 'https://github.com/Qbox-project/qbx_pawnshop'
version '1.0.0'

shared_scripts {
    '@qbx_core/import.lua',
    '@qbx_core/shared/locale.lua',
    'config.lua',
    'locales/en.lua',
    'locales/*.lua',
    '@ox_lib/init.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

client_script 'client/main.lua'

lua54 'yes'
use_experimental_fxv2_oal 'yes'
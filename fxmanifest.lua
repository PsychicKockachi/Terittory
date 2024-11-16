--[[ FX Information ]]
--
fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

--[[ Resource Information ]]
--
name 'SY_Bog'
version '1.0.0'
license 'GPL-3.0-or-later'
author 'SYNO'
repository ''

--[[ Manifest ]]
--
ui_page 'web/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

files {
    'locales/*.json',
    'web/index.html',
    'web/script.js',
    'web/style.css',
    'web/weapons/*.png'
}

dependencies {
    'es_extended',
    'ox_lib',
}

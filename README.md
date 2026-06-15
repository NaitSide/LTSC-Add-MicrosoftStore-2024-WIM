# LTSC-Add-MicrosoftStore-2024-WIM

**LTSC-Add-MicrosoftStore-2024-WIM** — это форк проекта [LTSC-Add-MicrosoftStore](https://github.com/minihub/LTSC-Add-MicrosoftStore).

## ⚙️ Что делает скрипт

> Скрипт вшивает Microsoft Store и связанные компоненты в распакованный WIM-образ Windows 11 LTSC 2024 / 24H2.

---

Если оригинальный **LTSC-Add-MicrosoftStore** вшивает Microsoft Store в уже установленную Windows 11 LTSC, то мой форк нужен для другой задачи: когда цель — сделать свою сборку Windows не колхозными методами, а официально задокументированными средствами Microsoft.

Внутри условного `w11_x64_LTSC_2024_official.iso` лежит WIM-образ. Его можно распаковать штатной консольной утилитой DISM, но руками это не очень удобно.

Поэтому для разворачивания WIM я использую **DISM++** — GUI-оболочку для работы с образами Windows.

<details>
<summary>🖼️ Скриншот DISM++</summary>

![DISM++](IMG/DISM++.png)

</details>

С помощью DISM++ WIM разворачивается на виртуальный VHD-диск, который можно создать средствами самой Windows.

<details>
<summary>🖼️ Создание и подключение VHD</summary>

![Создание и подключение VHD](IMG/screen-01-vhd.png)

</details>

После распаковки образа запускаем:

```bat
LTSC-Add-MicrosoftStore-24H2-WIM.bat
```

<details>
<summary>🖼️ Запуск скрипта</summary>

![Запуск скрипта](IMG/script-start.png)

</details>

После подтверждения действия любой клавишей вводим букву диска смонтированного VHD и ждём завершения установки.

Если всё прошло нормально, в конце скрипт покажет проверку установленных provisioned AppX-пакетов:

![Успешная установка](IMG/script-install-success.png)

---

## 📦 Содержимое проекта

```text
LTSC-Add-MicrosoftStore-2024-WIM
├── LTSC-Add-MicrosoftStore-24H2-WIM.bat   # Вшивание Store в offline WIM/VHD-образ
├── Packages                               # Пакеты Microsoft Store и зависимости
│   ├── Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
│   ├── Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.xml
│   ├── Microsoft.WindowsStore_8wekyb3d8bbwe.msixbundle
│   ├── Microsoft.WindowsStore_8wekyb3d8bbwe.xml
│   ├── Microsoft.StorePurchaseApp_8wekyb3d8bbwe.appxbundle
│   ├── Microsoft.StorePurchaseApp_8wekyb3d8bbwe.xml
│   ├── Microsoft.NET.Native.Framework.x64.2.2.appx
│   ├── Microsoft.NET.Native.Runtime.x64.2.2.appx
│   ├── Microsoft.UI.Xaml.x64.2.8.appx
│   ├── Microsoft.VCLibs.x64.14.00.appx
│   └── Microsoft.VCLibs.x64.14.00.UWPDesktop.appx
└── README.md
```

---

## 🧩 Устанавливаемые компоненты

**Основные пакеты:**

- **Microsoft Store**
- **Microsoft Store Purchase App**
- **Microsoft Desktop App Installer**

**Зависимости:**

- **Microsoft.UI.Xaml 2.8**
- **Microsoft.VCLibs 14.00**
- **Microsoft.VCLibs 14.00 UWPDesktop**
- **Microsoft.NET.Native.Framework 2.2**
- **Microsoft.NET.Native.Runtime 2.2**

**Архитектура:**

- x64

ARM64-пакеты в этом проекте не используются.

---

## 👨‍💻 Автор

**NaitSide** · Telegram: [@NaitLAB](https://t.me/NaitLAB)

---

## 🔗 Ссылки

- [GitHub NaitSide](https://github.com/NaitSide)
- [Оригинальный проект LTSC-Add-MicrosoftStore](https://github.com/minihub/LTSC-Add-MicrosoftStore)

---

## 📄 Лицензия

Скрипт распространяется "как есть" без гарантий.  
Используйте на свой страх и риск.

---

## 💝 Поддержка

Если скрипт помог — поставь ⭐ на GitHub!

Нашёл баг или есть предложение? Открой Issue.

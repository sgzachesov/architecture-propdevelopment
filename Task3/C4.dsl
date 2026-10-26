workspace {

  name "PropDevelopment — сервисы «Умный дом»"
  description "C4-модель: контекст и контейнеры для новых бизнес-функций «Умного дома» (интеллектуальный домофон и шлагбаум), интегрируемых через партнёрскую платформу"

  model {

    owner = person "Собственник" "Владелец квартиры; пользуется сервисами ЖКУ и управляет доступом «Умного дома» через мобильное приложение" {
      tags "Человек"
    }

    propdevelopment = softwareSystem "PropDevelopment" "Система PropDevelopment: онлайн-сделки, ЖКУ и новые функции «Умного дома» для собственников" {
      tags "Система"

      mobileApp = container "Витрина сервисов для собственников" "Мобильное приложение (iOS, Android)" "ИЗМЕНЕНО: добавлены экраны «Умного дома» — видеодомофон, шлагбаум, события доступа" {
        tags "Контейнер" "Изменённый"
      }

      smartHomeApp = container "smart-home-integration-app" "Kotlin, Spring Boot" "НОВЫЙ: шлюз интеграции с партнёром «Умного дома» — API для приложения, проверка прав доступа, журнал событий, контракты интеграции" {
        tags "Контейнер" "Новый"
      }

      smartHomeDb = container "smart-home-db" "PostgreSQL" "НОВАЯ БД: права доступа «Умного дома» и неизменяемый журнал событий доступа" {
        tags "База данных" "Новый"
      }

      tenantCore = container "tenant-core-app" "Kotlin, Spring Boot" "Предоставление услуг ЖКУ (без изменений)" {
        tags "Контейнер"
      }

      crm = container "CRM собственников" "Kotlin, Spring Boot" "Данные собственников и объектов" {
        tags "Контейнер"
      }

      crmDb = container "crm-tenant-db" "PostgreSQL" "База данных CRM по собственникам" {
        tags "База данных"
      }
    }

    partner = softwareSystem "Партнёрская платформа «Умный дом»" "Интеллектуальный домофон (биометрия по лицу) и шлагбаум (распознавание номеров), управление оборудованием" {
      tags "Внешняя система"

      partnerBackend = container "Платформа «Умного дома» (облако партнёра)" "Облачный сервис партнёра" "Обработка событий оборудования, биометрические шаблоны лиц и госномера (на стороне партнёра), управление доступом к устройствам" {
        tags "Контейнер"
      }

      partnerEquipment = container "Оборудование в объектах" "Видеодомофоны, шлагбаумы, камеры" "Видеодомофоны (биометрия по лицу), шлагбаумы (распознавание номеров), камеры" {
        tags "Контейнер"
      }
    }

    uk = softwareSystem "Поставщик ресурсов ЖКХ (УК)" "Существующая интеграция: платежи ЖКХ и информация о доме (не связана с «Умным домом»)" {
      tags "Внешняя система"
    }

    # ---- связи уровня «контекст» ----
    owner -> propdevelopment "Использует: сервисы ЖКУ и управление «Умным домом»" "HTTPS"
    propdevelopment -> partner "Проверка права доступа, синхронизация разрешений, конфигурация объекта" "HTTPS/REST, mTLS + OAuth 2.0"
    partner -> propdevelopment "События устройств: звонок, попытка доступа, статусы" "HTTPS, подписанные события"
    owner -> partner "Мультимедиа: видеозвонок и поток от домофона" "WebRTC (через партнёрскую платформу)"
    propdevelopment -> uk "Услуги ЖКУ и данные о доме" "HTTPS/REST"

    # ---- связи уровня «контейнер» ----
    owner -> mobileApp "Использует приложение" "HTTPS"
    mobileApp -> smartHomeApp "Управление доступом, события, статусы" "REST, HTTPS"
    mobileApp -> tenantCore "Сервисы ЖКУ (существующая функция)" "REST, HTTPS"
    smartHomeApp -> smartHomeDb "Чтение и запись прав доступа и журнала" "JDBC"
    smartHomeApp -> crm "Данные о собственниках и объектах" "REST"
    smartHomeApp -> partnerBackend "Проверка прав, синхронизация разрешений, приём событий" "HTTPS/REST, mTLS + OAuth 2.0, подписанные события" {
      tags "Новая интеграция"
    }
    partnerBackend -> partnerEquipment "Управление устройствами и телеметрия"
    crm -> crmDb "Чтение и запись данных собственников" "JDBC"
    tenantCore -> crm "Получение данных собственника" "REST"
  }

  views {

    systemContext propdevelopment {
      include *
      autoLayout lr
      title "Контекст — новые функции «Умного дома»"
    }

    container propdevelopment {
      include *
      include partnerBackend
      include partnerEquipment
      autoLayout lr
      title "Контейнеры — изменения ландшафта для «Умного дома»"
    }

    styles {

      element "Человек" {
        shape Person
        background #08427B
        color #ffffff
        fontSize 12
      }

      element "Система" {
        background #23A2D9
        color #ffffff
        fontSize 12
      }

      element "Внешняя система" {
        background #8C8496
        color #ffffff
        fontSize 12
      }

      element "Контейнер" {
        background #23A2D9
        color #ffffff
        fontSize 11
      }

      element "База данных" {
        shape Cylinder
        background #23A2D9
        color #ffffff
        fontSize 11
      }

      # новые элементы ландшафта
      element "Новый" {
        stroke #C0392B
        strokeWidth 2
        border dashed
      }

      # изменённые элементы ландшафта
      element "Изменённый" {
        stroke #E9A23B
        strokeWidth 2
      }

      # новая внешняя интеграция — акцент
      relationship "Новая интеграция" {
        color #C0392B
        thickness 2
      }
    }
  }
}
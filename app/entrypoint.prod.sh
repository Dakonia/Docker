#!/bin/sh

if [ "$DATABASE" = "postgres" ]; then
    # если база еще не запущена
    echo "DB not yet run..."

    # Проверяем доступность хоста и порта
    while ! nc -z "$POSTGRES_HOST" "$POSTGRES_PORT"; do
      sleep 0.1
    done

    echo "DB did run."
fi

# Удаляем все старые данные
python manage.py flush --no-input

# Ждем некоторое время перед созданием суперпользователя
sleep 5

# Выполняем миграции
python manage.py migrate

# Собираем статические файлы
python manage.py collectstatic --no-input

# Создаем суперпользователя, если его нет
echo "Creating superuser..."
echo "from django.contrib.auth.models import User; User.objects.filter(email='${DJANGO_SUPERUSER_EMAIL}').delete(); User.objects.create_superuser('${DJANGO_SUPERUSER_USERNAME}', '${DJANGO_SUPERUSER_EMAIL}', '${DJANGO_SUPERUSER_PASSWORD}')" | python manage.py shell || true


exec "$@"
import 'package:get/get.dart';

class MyLocalizations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'welcome': 'Welcome to Todozoid! Please sign in to continue.',
          'termsandconditions1': 'By signing in, you agree to our ',
          'termsandconditions2': 'terms and conditions.',
          'dashboard': 'Dashboard',
          'tasks': 'Tasks',
          'lists': 'Lists',
          'work': 'Work',
          'home': 'Home',
          'shopping': 'Shopping',
          'personal': 'Personal',
          'diary': 'Tasks diary',
          'categorieslist': 'Categories list',
          'settings': 'Settings',
          'theme': 'Theme',
          'light': 'Light',
          'dark': 'Dark',
          'review': 'Leave a review',
          'bug': 'Report a bug',
          'dailygoal': 'Daily goal',
          'noactive': 'No active tasks',
          'noactivelists': 'No active lists',
          'activetasks': 'Active tasks',
          'view': 'View',
          'thisweek': 'Tasks completed this week',
          'createTask': 'Create task',
          'updateTask': 'Update task',
          'newTaskTextField': 'New task',
          'category': 'Category',
          'day': 'Day',
          'time': 'Time',
          'selectDay': 'Select day',
          'selectTime': 'Select time',
          'note': 'Write a note...',
          'addSubtask': 'Add subtask',
          'newSubtaskTextField': 'New subtask',
          'sortByDate': 'Date',
          'sortByDescription': 'Description',
          'sortByCategory': 'Category',
          'when': 'When',
          'edit': 'Edit',
          'delete': 'Delete',
          'cancel': 'Cancel',
          'createList': 'Create list',
          'updateList': 'Update list',
          'listNameTextField': 'Name new list',
          'pickIcon': 'Pick icon (optional)',
          'addItem': 'Add item',
          'open': 'Open',
          'clear': 'Clear',
          'share': 'Share',
          'today': 'Today',
          'tomorrow': 'Tomorrow',
          'overdue': 'Task is overdue',
          'remindToday': 'Remind today at ',
          'remindTomorrow': 'Remind tomorrow at',
          'at': 'at',
          'signOut': 'Sign out',
          'categoryName': 'Category name',
          'newItem': 'New item',
          'taskReminder': 'Task reminder',
          'notifications': 'Notifications',
          'amountOfRepeats': 'Amount of repeats',
          'intervalOfRepeats': 'Interval of repeats (min)',
          'deleteAccount': 'Delete account',
          'alert': 'Alert',
          'alertDescription':
              'Account deletion requires an internet connection',
          'warning': 'Warning',
          'areYouSure':
              'Are you sure that you want to delete your data from an application?',
          'yes': 'Yes (requires re-authentication)',
          'no': 'No',
          'error': 'Error',
          'sameAccount': 'Use the same account for re-authentication',
        },
        'ru_RU': {
          'welcome':
              'Добро пожаловать в Todozoid! Пожалуйста, войдите, чтобы продолжить.',
          'termsandconditions1': 'Выполняя вход, вы соглашаетесь с нашими ',
          'termsandconditions2': 'условиями и положениями.',
          'dashboard': 'Дэшборд',
          'tasks': 'Задачи',
          'lists': 'Списки',
          'work': 'Работа',
          'home': 'Дом',
          'shopping': 'Покупки',
          'personal': 'Личное',
          'diary': 'Дневник задач',
          'categorieslist': 'Список категорий',
          'settings': 'Настройки',
          'theme': 'Тема',
          'light': 'Светлая',
          'dark': 'Темная',
          'review': 'Оставить отзыв',
          'bug': 'Сообщить об ошибке',
          'dailygoal': 'Дневная норма',
          'noactive': 'Нет активных задач',
          'noactivelists': 'Нет активных списков',
          'activetasks': 'Активные задачи',
          'view': 'Смотреть',
          'thisweek': 'Задач выполнено на этой неделе',
          'createTask': 'Создать задачу',
          'updateTask': 'Обновить задачу',
          'newTaskTextField': 'Новая задача',
          'category': 'Категория',
          'day': 'День',
          'time': 'Время',
          'selectDay': 'Выбрать день',
          'selectTime': 'Выбрать время',
          'note': 'Написать заметку...',
          'addSubtask': 'Добавить подзадачу',
          'newSubtaskTextField': 'Новая подзадача',
          'sortByDate': 'Дата',
          'sortByDescription': 'Описание',
          'sortByCategory': 'Категория',
          'when': 'Когда',
          'edit': 'Редак-ть',
          'delete': 'Удалить',
          'cancel': 'Отмена',
          'createList': 'Создать список',
          'updateList': 'Обновить список',
          'listNameTextField': 'Наименование списка',
          'pickIcon': 'Выбрать иконку (необязательно)',
          'addItem': 'Добавить элемент',
          'open': 'Открыть',
          'clear': 'Очистить',
          'share': 'Поделиться',
          'today': 'Сегодня',
          'tomorrow': 'Завтра',
          'overdue': 'Задача просрочена',
          'remindToday': 'Напомнить сегодня в ',
          'remindTomorrow': 'Напомнить завтра в ',
          'at': 'в',
          'signOut': 'Выйти',
          'categoryName': 'Наименование категории',
          'newItem': 'Новый элемент',
          'taskReminder': 'Напоминание о задаче',
          'notifications': 'Уведомления',
          'amountOfRepeats': 'Количество повторений',
          'intervalOfRepeats': 'Интервал повторений (мин)',
          'deleteAccount': 'Удалить аккаунт',
          'alert': 'Внимание',
          'alertDescription':
              'Для удаления аккаунта необходимо интернет-соединение',
          'warning': 'Внимание',
          'areYouSure':
              'Вы действительно хотите удалить данные своего аккаунта из приложения?',
          'yes': 'Да (требуется повторная аутентификация)',
          'no': 'Нет',
          'error': 'Ошибка',
          'sameAccount':
              'Используйте тот же аккаунт для повторной аутентификации',
        }
      };
}

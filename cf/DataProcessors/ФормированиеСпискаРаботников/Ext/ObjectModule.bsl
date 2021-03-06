﻿Перем мСоответствиеНазначений Экспорт;

Перем мСтруктураДляОтбораПоКатегориям;

#Если Клиент Тогда

Процедура ЗаполнитьНачальныеНастройки(НачальноеЗаполнение = Истина) Экспорт
	
	// структура представлений полей
	СтруктураПредставлениеПолей = Новый Структура();
	СтруктураФорматаПолей = Новый Структура();
	
	Если ИмяРегистра = "РаботникиОрганизаций" Тогда
		
		Если ВыбиратьСотрудника Тогда
			ТекстЗапроса =
			"ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
			|	РаботникиОрганизации.Сотрудник,
			|	РаботникиОрганизации.Сотрудник.Физлицо КАК Физлицо,
			|	РаботникиОрганизации.ПричинаИзмененияСостояния КАК ПричинаИзмененияСостояния,
			|	РаботникиОрганизации.Сотрудник.ВидЗанятости КАК ВидЗанятости,
			|	РаботникиОрганизации.Сотрудник.Код КАК ТабельныйНомер,
			|	РаботникиОрганизации.ЗанимаемыхСтавок КАК ЗанимаемыхСтавок,
			|	РаботникиОрганизации.Должность КАК Должность,
			|	РаботникиОрганизации.ПодразделениеОрганизации КАК Подразделение
			|ИЗ
			|	РегистрСведений.РаботникиОрганизаций.СрезПоследних(&ДатаАктуальности, Организация = &ГоловнаяОрганизация) КАК РаботникиОрганизации
			|		{ЛЕВОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
			|			ДатыПоследнихДвиженийРаботников.Период КАК Период,
			|			ДатыПоследнихДвиженийРаботников.Сотрудник КАК Сотрудник,
			|			ДанныеПоРаботникуПриНазначении.Регистратор КАК Приказ
			|		ИЗ
			|			(ВЫБРАТЬ
			|				МАКСИМУМ(Работники.Период) КАК Период,
			|				ТЧРаботникиОрганизации.Сотрудник КАК Сотрудник
			|			ИЗ
			|				РегистрСведений.РаботникиОрганизаций.СрезПоследних(&ДатаАктуальности, Организация = &ГоловнаяОрганизация) КАК ТЧРаботникиОрганизации
			|					ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.РаботникиОрганизаций КАК Работники
			|					ПО Работники.Период <= ТЧРаботникиОрганизации.Период
			|						И (Работники.ПричинаИзмененияСостояния = ЗНАЧЕНИЕ(Перечисление.ПричиныИзмененияСостояния.ПриемНаРаботу))
			|						И ТЧРаботникиОрганизации.Сотрудник = Работники.Сотрудник
			|			{ГДЕ
			|				ТЧРаботникиОрганизации.Должность КАК Должность,
			|				ТЧРаботникиОрганизации.Сотрудник.Код КАК ТабельныйНомер,
			|				ТЧРаботникиОрганизации.ЗанимаемыхСтавок КАК ЗанимаемыхСтавок,
			|				ТЧРаботникиОрганизации.ОбособленноеПодразделение КАК ОбособленноеПодразделение,
			|				ТЧРаботникиОрганизации.ПодразделениеОрганизации КАК Подразделение}
			|			
			|			СГРУППИРОВАТЬ ПО
			|				ТЧРаботникиОрганизации.Сотрудник) КАК ДатыПоследнихДвиженийРаботников
			|				ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.РаботникиОрганизаций КАК ДанныеПоРаботникуПриНазначении
			|				ПО ДатыПоследнихДвиженийРаботников.Период = ДанныеПоРаботникуПриНазначении.Период
			|					И ДатыПоследнихДвиженийРаботников.Сотрудник = ДанныеПоРаботникуПриНазначении.Сотрудник) КАК ПриказыОПриеме
			|		ПО РаботникиОрганизации.Сотрудник = ПриказыОПриеме.Сотрудник}
			|		//ДАННЫЕ О ФИЗЛИЦЕ: СОЕДИНЕНИЯ
			|		//СОЕДИНЕНИЯ СВОЙСТВ И КАТЕГОРИЙ
			|//УСЛОВИЕ
			|{ГДЕ
			|	РаботникиОрганизации.Сотрудник КАК Работник,
			|	РаботникиОрганизации.Сотрудник.Родитель КАК Группа,
			|	РаботникиОрганизации.Должность.* КАК Должность,
			|	РаботникиОрганизации.Сотрудник.Код КАК ТабельныйНомер,
			|	РаботникиОрганизации.ЗанимаемыхСтавок КАК ЗанимаемыхСтавок,
			|	ПриказыОПриеме.Период КАК ДатаПриема,
			|	РаботникиОрганизации.Сотрудник.ВидЗанятости КАК ВидЗанятости,
			|	РаботникиОрганизации.ПодразделениеОрганизации.* КАК Подразделение,
			|	РаботникиОрганизации.ОбособленноеПодразделение.* КАК ОбособленноеПодразделение
			|	//ДАННЫЕ О ФИЗЛИЦЕ: ПОЛЯ
			|	//СВОЙСТВА
			|	//КАТЕГОРИИ
			|}
			|
			|УПОРЯДОЧИТЬ ПО
			|	РаботникиОрганизации.Сотрудник.Наименование";
			
			
		Иначе
			ТекстЗапроса =
			"ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
			|	РаботникиОрганизации.Сотрудник.Физлицо КАК Физлицо
			|ИЗ
			|	РегистрСведений.РаботникиОрганизаций.СрезПоследних(&ДатаАктуальности, Организация = &ГоловнаяОрганизация) КАК РаботникиОрганизации
			|		{ЛЕВОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
			|			ДатыПоследнихДвиженийРаботников.Период КАК Период,
			|			ДатыПоследнихДвиженийРаботников.Организация КАК Организация,
			|			ДатыПоследнихДвиженийРаботников.Физлицо КАК Физлицо,
			|			ДанныеПоРаботникуПриНазначении.Регистратор КАК Приказ
			|		ИЗ
			|			(ВЫБРАТЬ
			|				МАКСИМУМ(Работники.Период) КАК Период,
			|				ТЧРаботникиОрганизации.Сотрудник.Физлицо КАК Физлицо,
			|				ТЧРаботникиОрганизации.Организация КАК Организация
			|			ИЗ
			|				РегистрСведений.РаботникиОрганизаций.СрезПоследних(&ДатаАктуальности, Организация = &ГоловнаяОрганизация) КАК ТЧРаботникиОрганизации
			|					ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.РаботникиОрганизаций КАК Работники
			|					ПО Работники.Период <= ТЧРаботникиОрганизации.Период
			|						И (Работники.ПричинаИзмененияСостояния = ЗНАЧЕНИЕ(Перечисление.ПричиныИзмененияСостояния.ПриемНаРаботу))
			|						И ТЧРаботникиОрганизации.Сотрудник = Работники.Сотрудник
			|			{ГДЕ
			|				ТЧРаботникиОрганизации.Должность КАК Должность,
			|				ТЧРаботникиОрганизации.Сотрудник.Код КАК ТабельныйНомер,
			|				ТЧРаботникиОрганизации.ЗанимаемыхСтавок КАК ЗанимаемыхСтавок,
			|				ТЧРаботникиОрганизации.ОбособленноеПодразделение КАК ОбособленноеПодразделение,
			|				ТЧРаботникиОрганизации.ПодразделениеОрганизации КАК Подразделение}
			|			
			|			СГРУППИРОВАТЬ ПО
			|				ТЧРаботникиОрганизации.Сотрудник.Физлицо,
			|				ТЧРаботникиОрганизации.Организация) КАК ДатыПоследнихДвиженийРаботников
			|				ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.РаботникиОрганизаций КАК ДанныеПоРаботникуПриНазначении
			|				ПО ДатыПоследнихДвиженийРаботников.Период = ДанныеПоРаботникуПриНазначении.Период
			|					И ДатыПоследнихДвиженийРаботников.Физлицо = ДанныеПоРаботникуПриНазначении.Сотрудник.Физлицо
			|					И ДатыПоследнихДвиженийРаботников.Организация = ДанныеПоРаботникуПриНазначении.Сотрудник.Организация) КАК ПриказыОПриеме
			|		ПО РаботникиОрганизации.Сотрудник.Физлицо = ПриказыОПриеме.Физлицо
			|			И РаботникиОрганизации.Сотрудник.Организация = ПриказыОПриеме.Организация}
			|		//ДАННЫЕ О ФИЗЛИЦЕ: СОЕДИНЕНИЯ
			|		//СОЕДИНЕНИЯ СВОЙСТВ И КАТЕГОРИЙ
			|//УСЛОВИЕ
			|{ГДЕ
			|	РаботникиОрганизации.Сотрудник КАК Работник,
			|	РаботникиОрганизации.Сотрудник.Родитель КАК Группа,
			|	РаботникиОрганизации.Должность.* КАК Должность,
			|	РаботникиОрганизации.Сотрудник.Код КАК ТабельныйНомер,
			|	РаботникиОрганизации.ЗанимаемыхСтавок КАК ЗанимаемыхСтавок,
			|	ПриказыОПриеме.Период КАК ДатаПриема,
			|	РаботникиОрганизации.Сотрудник.ВидЗанятости КАК ВидЗанятости,
			|	РаботникиОрганизации.ПодразделениеОрганизации.* КАК Подразделение,
			|	РаботникиОрганизации.ОбособленноеПодразделение.* КАК ОбособленноеПодразделение
			|	//ДАННЫЕ О ФИЗЛИЦЕ: ПОЛЯ
			|	//СВОЙСТВА
			|	//КАТЕГОРИИ
			|}
			|
			|УПОРЯДОЧИТЬ ПО
			|	РаботникиОрганизации.Сотрудник.Физлицо.Наименование";
		КонецЕсли;
	
	
	КонецЕсли;
	
	Если Не ВключатьУволенных Тогда
		СтрокаУсловия =
		"ГДЕ
		|	РаботникиОрганизации.ПричинаИзмененияСостояния <> ЗНАЧЕНИЕ(Перечисление.ПричиныИзмененияСостояния.Увольнение)
		|";
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "//УСЛОВИЕ", СтрокаУсловия);
		
	ИначеЕсли ЗначениеЗаполнено(ДатаУволенных) Тогда
		СтрокаУсловия =
		"ГДЕ
		|	(РаботникиОрганизации.ПричинаИзмененияСостояния <> ЗНАЧЕНИЕ(Перечисление.ПричиныИзмененияСостояния.Увольнение)) ИЛИ (РаботникиОрганизации.Период > &ДатаУволенных)
		|";
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "//УСЛОВИЕ", СтрокаУсловия);
		
	КонецЕсли;
	
	// Преобразуем текст запроса для получения полной информации о физлице
	Если ИмяРегистра = "РаботникиОрганизаций" Тогда
		УправлениеОтчетами.ДобавитьВТекстПостроителяДанныеОФизлице(ТекстЗапроса, СтруктураПредставлениеПолей, СтруктураФорматаПолей, "РаботникиОрганизации", "Сотрудник.Физлицо");
	Иначе
		УправлениеОтчетами.ДобавитьВТекстПостроителяДанныеОФизлице(ТекстЗапроса, СтруктураПредставлениеПолей, СтруктураФорматаПолей, "РаботникиОрганизации", "Физлицо");
	КонецЕсли;
	
    ПостроительОтчета.Текст = ТекстЗапроса;
	
	//представление полей запроса
	СтруктураПредставлениеПолей.Вставить("Группа",						"Группа сотрудников");
	СтруктураПредставлениеПолей.Вставить("ОбособленноеПодразделение",	"Организация");
	Если ИмяРегистра = "РаботникиОрганизаций" Тогда 
		СтруктураПредставлениеПолей.Вставить("ВидЗанятости",			"Вид занятости");
	КонецЕсли;
	СтруктураПредставлениеПолей.Вставить("ДатаПриема",					"Дата приема");
	СтруктураПредставлениеПолей.Вставить("ЗанимаемыхСтавок",			"Занимаемых ставок");
	
	УправлениеОтчетами.ЗаполнитьПредставленияПолей(СтруктураПредставлениеПолей, ПостроительОтчета);
	
	Если НачальноеЗаполнение Тогда
		// отборы по умолчанию
		МассивОтбора = Новый Массив;
		Если ИмяРегистра = "РаботникиОрганизаций" Тогда
			МассивОтбора.Добавить("ОбособленноеПодразделение");
		КонецЕсли;
		МассивОтбора.Добавить("Подразделение");
		МассивОтбора.Добавить("Должность");
		МассивОтбора.Добавить("Работник");
		УправлениеОтчетами.ЗаполнитьОтбор(МассивОтбора, ПостроительОтчета);
		ПостроительОтчета.Отбор.Работник.ВидСравнения = ВидСравнения.ВСписке;
	КонецЕсли;
	
КонецПроцедуры

Функция ПолучитьСписокРаботников() Экспорт
	
	//Если НЕ УправлениеОтчетами.ЗадатьПараметрыОтбораПоКатегориям(ПостроительОтчета, мСтруктураДляОтбораПоКатегориям) Тогда
	//	//повторные отборы по категориям
	//	Возврат Новый Структура("Команда,Данные,Реквизиты","ЗаполнитьСписокРаботников");
	//КонецЕсли;
	
	ПостроительОтчета.Параметры.Вставить("ДатаАктуальности", ДатаАктуальности);
	ПостроительОтчета.Параметры.Вставить("ДатаАктуальности_Год", Год(ДатаАктуальности));
	ПостроительОтчета.Параметры.Вставить("ДатаАктуальности_Месяц", Месяц(ДатаАктуальности));
	ПостроительОтчета.Параметры.Вставить("ДатаАктуальности_День", День(ДатаАктуальности));
	ПостроительОтчета.Параметры.Вставить("ДатаУволенных", ДатаУволенных);
	
	Если ИсполнятьЗапрос Тогда
		ПостроительОтчета.Выполнить();
		РезультатОтбора = ПостроительОтчета.Результат;
		Если РезультатОтбора.Пустой() Тогда
			ОбщегоНазначения.СообщитьОбОшибке("Не обнаружено работников, удовлетворяющих указанным условиям!");
		КонецЕсли;
		
		Возврат Новый Структура("Команда,Данные,Реквизиты","ЗаполнитьСписокРаботников",РезультатОтбора,Реквизиты)
	Иначе
		ПостроительЗапроса = Новый ПостроительЗапроса(ПостроительОтчета.Текст);
		Для каждого Параметр Из ПостроительОтчета.Параметры Цикл
			ПостроительЗапроса.Параметры.Вставить(Параметр.Ключ,Параметр.Значение);
		КонецЦикла; 
		Для каждого ЭлементОтбора Из ПостроительОтчета.Отбор Цикл
			Если ЭлементОтбора.Использование и ЗначениеЗаполнено(ЭлементОтбора.ПутьКДанным) Тогда
				НовыйОтбор = ПостроительЗапроса.Отбор.Добавить(ЭлементОтбора.ПутьКДанным,ЭлементОтбора.Имя,ЭлементОтбора.Представление);
				НовыйОтбор.ВидСравнения = ЭлементОтбора.ВидСравнения;
				НовыйОтбор.Значение = ЭлементОтбора.Значение;
				НовыйОтбор.ЗначениеПо = ЭлементОтбора.ЗначениеПо;
				НовыйОтбор.ЗначениеС = ЭлементОтбора.ЗначениеС;
				НовыйОтбор.Использование = Истина;
			КонецЕсли;
		КонецЦикла; 
		Возврат Новый Структура("Команда,ПостроительЗапроса,Реквизиты","ЗаполнитьПостроительЗапроса",ПостроительЗапроса,Реквизиты)
	КонецЕсли;
	
КонецФункции // ПолучитьСписокРаботников()

#КонецЕсли

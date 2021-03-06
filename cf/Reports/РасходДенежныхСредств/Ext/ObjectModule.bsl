﻿Перем СохраненнаяНастройка Экспорт;
Перем Расшифровки Экспорт;

Перем ПромежуточныеДанные Экспорт;

#Если Клиент Тогда

Процедура СформироватьОтчет(Результат = Неопределено, ДанныеРасшифровки = Неопределено, ВыводВФормуОтчета = Истина, ВнешниеНаборыДанных = Неопределено) Экспорт
	
	// Проверим заполнение обязательных реквизитов
	Если ПроверитьЗаполнениеОбязательныхРеквизитов() Тогда
		Возврат;
	КонецЕсли;
	
	Результат.Очистить();
	
	Настройки = КомпоновщикНастроек.ПолучитьНастройки();
	ВыводЗаголовкаОтчета(ЭтотОбъект, Результат);
	ДоработатьКомпоновщикПередВыводом(ВнешниеНаборыДанных);
	КомпоновщикНастроек.Восстановить();
	НастройкаКомпоновкиДанных = КомпоновщикНастроек.ПолучитьНастройки();
	КомпоновщикНастроек.ЗагрузитьНастройки(Настройки);
	СтандартныеОтчеты.ВывестиОтчет(ЭтотОбъект, Результат, ДанныеРасшифровки, ВыводВФормуОтчета, ВнешниеНаборыДанных, Истина, НастройкаКомпоновкиДанных);
	
	// Выполним дополнительную обработку Результата отчета
	ОбработкаРезультатаОтчета(Результат);
	
КонецПроцедуры

// В процедуре можно доработать компоновщик перед выводом в отчет
// Изменения сохранены не будут
Процедура ДоработатьКомпоновщикПередВыводом(ВнешниеНаборыДанных) Экспорт
		
	ВнешниеНаборыДанных = Новый Структура;
	ВыборкаДанных = ПолучитьВыборку();
	ВнешниеНаборыДанных.Вставить("ТаблицаДанных", ВыборкаДанных);
	
	ТиповыеОтчеты.УстановитьПараметр(КомпоновщикНастроек, "Периодичность", Интервал);
	ТиповыеОтчеты.УстановитьПараметр(КомпоновщикНастроек, "НачалоПериода", НачалоДня(НачалоПериода));
	ТиповыеОтчеты.УстановитьПараметр(КомпоновщикНастроек, "КонецПериода" , КонецДня(КонецПериода));
	
	ТипДополнения = СтандартныеОтчеты.ПолучитьТипДополненияПоИнтервалу(Интервал);

	Для каждого ЭлементСтруктуры Из КомпоновщикНастроек.Настройки.Структура Цикл
		Если ТипЗнч(ЭлементСтруктуры) = Тип("ДиаграммаКомпоновкиДанных") Тогда
			ЭлементГруппировок = ЭлементСтруктуры.Точки;
			Для каждого Группировка Из ЭлементГруппировок Цикл
				СтандартныеОтчеты.УстановитьДополнениеПоляГруппировки(Группировка, ТипДополнения);
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;
	
	СтруктураПараметр   = СтандартныеОтчеты.ПолучитьОписаниеСтруктурыПараметра();
	ПромежуточныеДанные = СтандартныеОтчеты.ПолучитьОписаниеТаблицыПромежуточныеДанные();
	
	Выборка = ВыборкаДанных.Выбрать();
	Пока Выборка.Следующий() Цикл
		ЗаполнитьЗначенияСвойств(СтруктураПараметр, Выборка);
		СтруктураПараметр.Знак         = "+";
		СтруктураПараметр.Субконто1    = Выборка.ВидРасхода;
		СтандартныеОтчеты.ДобавитьЗаписьВТаблицуПромежуточныеДанные(ПромежуточныеДанные, СтруктураПараметр);
	КонецЦикла;
	
КонецПроцедуры

Функция ПолучитьВыборку() 
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
	|	СчетаКонтрагентов.Ссылка КАК Счет
	|ПОМЕСТИТЬ СчетаКД
	|ИЗ
	|	ПланСчетов.Хозрасчетный.ВидыСубконто КАК СчетаКонтрагентов
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ (ВЫБРАТЬ РАЗЛИЧНЫЕ
	|			ХозрасчетныйВидыСубконто.Ссылка КАК Ссылка
	|		ИЗ
	|			ПланСчетов.Хозрасчетный.ВидыСубконто КАК ХозрасчетныйВидыСубконто
	|		ГДЕ
	|			ХозрасчетныйВидыСубконто.ВидСубконто = ЗНАЧЕНИЕ(ПланВидовХарактеристик.ВидыСубконтоХозрасчетные.Договоры)) КАК СчетаДоговоров
	|		ПО СчетаКонтрагентов.Ссылка = СчетаДоговоров.Ссылка
	|ГДЕ
	|	СчетаКонтрагентов.ВидСубконто = ЗНАЧЕНИЕ(ПланВидовХарактеристик.ВидыСубконтоХозрасчетные.Контрагенты)
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Счет
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ВЫБОР
	|		КОГДА ВложенныйЗапрос.ВидДоговора = ЗНАЧЕНИЕ(Перечисление.ВидыДоговоровКонтрагентов.СПоставщиком)
	|			ТОГДА 21
	|		КОГДА ВложенныйЗапрос.ВидДоговора = ЗНАЧЕНИЕ(Перечисление.ВидыДоговоровКонтрагентов.СКомитентом)
	|			ТОГДА 22
	|		КОГДА ВложенныйЗапрос.ВидДоговора = ЗНАЧЕНИЕ(Перечисление.ВидыДоговоровКонтрагентов.СПокупателем)
	|			ТОГДА 23
	|		КОГДА ВложенныйЗапрос.ВидДоговора = ЗНАЧЕНИЕ(Перечисление.ВидыДоговоровКонтрагентов.СКомиссионером)
	|			ТОГДА 24
	|		ИНАЧЕ 25
	|	КОНЕЦ КАК Приоритет,
	|	Хозрасчетный.Наименование КАК ВидРасхода,
	|	ВложенныйЗапрос.Сумма,
	|	ВложенныйЗапрос.Период КАК Период,
	|	ВложенныйЗапрос.Счет,
	|	ВложенныйЗапрос.КорСчет,
	|	ВложенныйЗапрос.БухВидРесурса
	|ИЗ
	|	(ВЫБРАТЬ
	|		ВЫРАЗИТЬ(ОплатаКонтрагентам.КорСубконто2 КАК Справочник.ДоговорыКонтрагентов).ВидДоговора КАК ВидДоговора,
	|		ОплатаКонтрагентам.КорСчет КАК КорСчет,
	|		ЕСТЬNULL(ОплатаКонтрагентам.СуммаОборотКт, 0) КАК Сумма,
	|		ОплатаКонтрагентам.Период КАК Период,
	|		ОплатаКонтрагентам.Счет КАК Счет,
	|		""Кт"" КАК БухВидРесурса
	|	ИЗ
	|		РегистрБухгалтерии.Хозрасчетный.Обороты(
	|				&НачалоПериода,
	|				&КонецПериода,
	|				Месяц,
	|				Счет В ИЕРАРХИИ (&СчетаДС),
	|				,
	|				Организация = &Организация {(Организация) КАК Организация},
	|				КорСчет В
	|					(ВЫБРАТЬ
	|						СчетаКД.Счет
	|					ИЗ
	|						СчетаКД КАК СчетаКД),
	|				&ВидыСубконтоКД) КАК ОплатаКонтрагентам) КАК ВложенныйЗапрос
	|		ЛЕВОЕ СОЕДИНЕНИЕ ПланСчетов.Хозрасчетный КАК Хозрасчетный
	|		ПО (ВЫБОР
	|				КОГДА ВложенныйЗапрос.КорСчет.Родитель <> ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.ПустаяСсылка)
	|						И ВложенныйЗапрос.КорСчет.Родитель <> ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.ПереводыВПути_)
	|					ТОГДА ВложенныйЗапрос.КорСчет.Родитель
	|				ИНАЧЕ ВложенныйЗапрос.КорСчет
	|			КОНЕЦ = Хозрасчетный.Ссылка)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	90,
	|	Хозрасчетный.Наименование,
	|	ЕСТЬNULL(ПрочийРасход.СуммаОборотКт, 0),
	|	ПрочийРасход.Период,
	|	ПрочийРасход.Счет,
	|	ПрочийРасход.КорСчет,
	|	""Кт""
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.Обороты(
	|			&НачалоПериода,
	|			&КонецПериода,
	|			Месяц,
	|			Счет В ИЕРАРХИИ (&СчетаДС),
	|			,
	|			Организация = &Организация,
	|			(НЕ КорСчет В
	|						(ВЫБРАТЬ
	|							СчетаКД.Счет
	|						ИЗ
	|							СчетаКД КАК СчетаКД))
	|				И (НЕ КорСчет = ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.Вспомогательный))
	|				И (НЕ КорСчет В ИЕРАРХИИ (&СчетаДС))
	|				И (НЕ КорСчет В ИЕРАРХИИ (ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.РасчетыСПодотчетнымиЛицами_))),
	|			) КАК ПрочийРасход
	|		ЛЕВОЕ СОЕДИНЕНИЕ ПланСчетов.Хозрасчетный КАК Хозрасчетный
	|		ПО (ВЫБОР
	|				КОГДА ПрочийРасход.КорСчет.Родитель В ИЕРАРХИИ (ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.РасчетыПоНалогам))
	|					ТОГДА ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.РасчетыПоНалогам)
	|				КОГДА ПрочийРасход.КорСчет.Родитель В ИЕРАРХИИ (ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.РасчетыПоСоциальномуСтрахованию))
	|					ТОГДА ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.РасчетыПоСоциальномуСтрахованию)
	|				КОГДА ПрочийРасход.КорСчет.Родитель = ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.НДСпоПриобретеннымЦенностям)
	|					ТОГДА ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.Материалы)
	|				КОГДА ПрочийРасход.КорСчет.Родитель <> ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.ПустаяСсылка)
	|						И ПрочийРасход.КорСчет.Родитель <> ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.ПереводыВПути_)
	|					ТОГДА ПрочийРасход.КорСчет.Родитель
	|				ИНАЧЕ ПрочийРасход.КорСчет
	|			КОНЕЦ = Хозрасчетный.Ссылка)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	80,
	|	""Расчеты с подотчетными лицами (израсходовано)"",
	|	ЕСТЬNULL(ПрочийРасход.СуммаОборотКт, 0),
	|	ПрочийРасход.Период,
	|	ПрочийРасход.Счет,
	|	ПрочийРасход.КорСчет,
	|	""Кт""
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.Обороты(
	|			&НачалоПериода,
	|			&КонецПериода,
	|			Месяц,
	|			Счет В ИЕРАРХИИ (ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.РасчетыСПодотчетнымиЛицами_)),
	|			,
	|			Организация = &Организация {(Организация) КАК Организация},
	|			(НЕ КорСчет В
	|						(ВЫБРАТЬ
	|							СчетаКД.Счет
	|						ИЗ
	|							СчетаКД КАК СчетаКД))
	|				И (НЕ КорСчет = ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.Вспомогательный))
	|				И (НЕ КорСчет В ИЕРАРХИИ (&СчетаДС))
	|				И (НЕ КорСчет В ИЕРАРХИИ (ЗНАЧЕНИЕ(ПланСчетов.Хозрасчетный.РасчетыСПодотчетнымиЛицами_))),
	|			) КАК ПрочийРасход";
	
	Запрос.УстановитьПараметр("НачалоПериода", НачалоПериода);	
	Запрос.УстановитьПараметр("КонецПериода" , КонецДня(КонецПериода));
	Запрос.УстановитьПараметр("Организация"  , Организация);
	Если Не ЗначениеЗаполнено(Организация) Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "Организация = &Организация", "");
	КонецЕсли;
	ВидыСубконтоКД = Новый Массив;
	ВидыСубконтоКД.Добавить(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Контрагенты);
	ВидыСубконтоКД.Добавить(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Договоры);
	Запрос.УстановитьПараметр("ВидыСубконтоКД", ВидыСубконтоКД);
	
	СчетаДС = Новый Массив;
	СчетаДС.Добавить(ПланыСчетов.Хозрасчетный.КассаОрганизации);
	СчетаДС.Добавить(ПланыСчетов.Хозрасчетный.ОперационнаяКасса);
	СчетаДС.Добавить(ПланыСчетов.Хозрасчетный.КассаОрганизацииВал);
	СчетаДС.Добавить(ПланыСчетов.Хозрасчетный.РасчетныеСчета);
	СчетаДС.Добавить(ПланыСчетов.Хозрасчетный.ВалютныеСчета);
	СчетаДС.Добавить(ПланыСчетов.Хозрасчетный.СпециальныеСчета);
	СчетаДС.Добавить(ПланыСчетов.Хозрасчетный.ПереводыВПути);
	СчетаДС.Добавить(ПланыСчетов.Хозрасчетный.ПереводыВПутиВал);
	Запрос.УстановитьПараметр("СчетаДС", СчетаДС);
	Если Интервал = 6 Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "Месяц", "День");
	ИначеЕсли Интервал = 7 Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "Месяц", "Неделя");
	ИначеЕсли Интервал = 8 Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "Месяц", "Декада");
	ИначеЕсли Интервал = 10 Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "Месяц", "Квартал");
	ИначеЕсли Интервал = 11 Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "Месяц", "Полугодие");
	ИначеЕсли Интервал = 12 Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "Месяц", "Год");
	КонецЕсли;
	
	Возврат Запрос.Выполнить();
	
КонецФункции

Процедура ВыводЗаголовкаОтчета(ОтчетОбъект, Результат)
	
	МакетЗаголовок = ПолучитьОбщийМакет("ЗаголовокОтчета");
	ОбластьЗаголовок = МакетЗаголовок.ПолучитьОбласть("Заголовок");
	
	ОбластьЗаголовок.Параметры.ЗаголовокОтчета = ПолучитьТекстЗаголовка();
	
	Результат.Вывести(ОбластьЗаголовок);
			
КонецПроцедуры

Функция ПолучитьТекстЗаголовка(ОрганизацияВНачале = Истина) Экспорт 
	
	ЗаголовокОтчета = "Расход денежных средств";
	
	Возврат СтандартныеОтчеты.ПолучитьТекстЗаголовка(ЭтотОбъект, ЗаголовокОтчета, ОрганизацияВНачале);
	
КонецФункции

Процедура ОбработкаРезультатаОтчета(Результат)
	
	СтандартныеОтчеты.ОбработкаРезультатаОтчета(ЭтотОбъект, Результат);
	
КонецПроцедуры

Процедура УстановитьИнтервал() Экспорт
	
	СтандартныеОтчеты.УстановитьИнтервал(ЭтотОбъект);
	
КонецПроцедуры

Функция ПроверитьЗаполнениеОбязательныхРеквизитов()
	
	Отказ = Ложь;
	Если Не ЗначениеЗаполнено(НачалоПериода) ИЛИ Не ЗначениеЗаполнено(КонецПериода) Тогда
		Сообщить("Не указан период формирования отчета", СтатусСообщения.Важное);
		Отказ = Истина;
	ИначеЕсли НачалоПериода > КонецПериода Тогда
		Сообщить("Дата начала периода не может быть больше даты конца периода", СтатусСообщения.Важное);
		Отказ = Истина;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Интервал) Тогда
		Сообщить("Не указан интервал", СтатусСообщения.Важное); 
		Отказ = Истина;
	КонецЕсли;
	
	Возврат Отказ;
	
КонецФункции
	
// Для настройки отчета (расшифровка и др.)
Процедура Настроить(Отбор, КомпоновщикНастроекОсновногоОтчета = Неопределено) Экспорт
	
	ТиповыеОтчеты.НастроитьТиповойОтчет(ЭтотОбъект, Отбор, КомпоновщикНастроекОсновногоОтчета);
	
КонецПроцедуры

Процедура СохранитьНастройку() Экспорт
	
	СтандартныеОтчеты.СохранитьНастройку(ЭтотОбъект);
	
КонецПроцедуры

// Процедура заполняет параметры отчета по элементу справочника из переменной СохраненнаяНастройка.
Процедура ПрименитьНастройку() Экспорт
	
	Если СохраненнаяНастройка.Пустая() Тогда
		Возврат;
	КонецЕсли;
	 
	СтруктураПараметров = СохраненнаяНастройка.ХранилищеНастроек.Получить();
	ТиповыеОтчеты.ПрименитьСтруктуруПараметровОтчета(ЭтотОбъект, СтруктураПараметров);
	
КонецПроцедуры

Процедура ИнициализацияОтчета() Экспорт
	
	ТиповыеОтчеты.УстановитьПараметр(КомпоновщикНастроек, "НачалоПериода", НачалоПериода);
	ТиповыеОтчеты.УстановитьПараметр(КомпоновщикНастроек, "КонецПериода",  КонецПериода);
	
КонецПроцедуры

Расшифровки = Новый СписокЗначений;

НастройкаПериода = Новый НастройкаПериода;

#КонецЕсли
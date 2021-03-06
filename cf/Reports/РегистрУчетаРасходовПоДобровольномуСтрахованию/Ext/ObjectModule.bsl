﻿#Если Клиент Тогда
	
Перем НП Экспорт;

// Выполняет запрос и формирует табличный документ-результат отчета
// в соответствии с настройками, заданными значениями реквизитов отчета.
//
// Параметры:
//	ДокументРезультат - табличный документ, формируемый отчетом
//	ПоказыватьЗаголовок - признак видимости строк с заголовком отчета
//	ВысотаЗаголовка - параметр, через который возвращается высота заголовка в строках 
//
Процедура СформироватьОтчет(ДокументРезультат, ПоказыватьЗаголовок, ВысотаЗаголовка, ТолькоЗаголовок = Ложь) Экспорт

	
	НачалоПериода = НачалоМесяца(ДатаНач);
	КонецПериода  = КонецМесяца(ДатаКон);

	ДокументРезультат.Очистить();

	Макет = ПолучитьМакет("Отчет");

	ОбластьЗаголовок  = Макет.ПолучитьОбласть("Заголовок");

	ОбластьЗаголовок.Параметры.НачалоПериода       = Формат(НачалоПериода, "ДФ=dd.MM.yyyy");
	ОбластьЗаголовок.Параметры.КонецПериода        = Формат(КонецПериода, "ДФ=dd.MM.yyyy");
	СведенияОбОрганизации = УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(Организация);
	НазваниеОрганизации = ФормированиеПечатныхФорм.ОписаниеОрганизации(СведенияОбОрганизации, "НаименованиеДляПечатныхФорм");
	ОбластьЗаголовок.Параметры.НазваниеОрганизации = НазваниеОрганизации;
	ОбластьЗаголовок.Параметры.ИННОрганизации      = "" + Организация.ИНН + " / " + Организация.КПП;
	ДокументРезультат.Вывести(ОбластьЗаголовок);

	// Параметр для показа заголовка
	ВысотаЗаголовка = ДокументРезультат.ВысотаТаблицы;

	// Когда нужен только заголовок:
	Если ТолькоЗаголовок Тогда
		Возврат;
	КонецЕсли;

	// Проверим заполнение обязательных реквизитов
	Если НалоговыйУчет.ПроверитьЗаполнениеОбязательныхРеквизитов(ДатаНач,ДатаКон,Организация) Тогда
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ВысотаЗаголовка) Тогда
		ДокументРезультат.Область("R1:R" + ВысотаЗаголовка).Видимость = ПоказыватьЗаголовок;
	КонецЕсли;

	Страхование1 = Перечисления.ВидыРБП.ДолгосрочноеСтрахованиеЖизни;
	Страхование2 = Перечисления.ВидыРБП.СтрахованиеНаОплатуМедицинскихРасходов;
	Страхование3 = Перечисления.ВидыРБП.СтрахованиеНаСлучайСмертиИУтратыРаботоспособности;

	ВидыРБП = Новый Массив;
	ВидыРБП.Добавить(Страхование1);
	ВидыРБП.Добавить(Страхование2);
	ВидыРБП.Добавить(Страхование3);
	
	Счета = Новый Массив;
	Счета.Добавить(ПланыСчетов.Хозрасчетный.РасходыБудущихПериодовНаДобровольноеСтрахованиеРаботников);
	Счета.Добавить(ПланыСчетов.Хозрасчетный.ПлатежиПоДобровольномуСтрахованиюРаботников);
	
	ВидыСубконто = Новый Массив;
	ВидыСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.РасходыБудущихПериодов);
	ВидыСубконто.Добавить(ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.РаботникиОрганизаций);

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("НачалоПериода", НачалоПериода);
	Запрос.УстановитьПараметр("КонецПериода",  КонецПериода);
	Запрос.УстановитьПараметр("Счет",          Счета);
	Запрос.УстановитьПараметр("Организация",   Организация);
	Запрос.УстановитьПараметр("ВидРБП",        ВидыРБП);
	Запрос.УстановитьПараметр("ВидыСубконто",  ВидыСубконто);
	
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ОборотыДтКт.Период КАК ДатаОперации,
	|	ОборотыДтКт.СубконтоКт1 КАК РБП,
	|	ОборотыДтКт.СубконтоКт2 КАК Работник,
	|	ОборотыДтКт.СубконтоКт2.Код КАК ТабельныйНомер,
	|	СУММА(ОборотыДтКт.СуммаНУОборотКт) КАК Сумма
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.ОборотыДтКт(&НачалоПериода, &КонецПериода, Регистратор, , , СчетКт В ИЕРАРХИИ (&Счет), &ВидыСубконто, Организация = &Организация) КАК ОборотыДтКт
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.РаботникиОрганизаций.СрезПоследних(&КонецПериода, ) КАК РаботникиОрганизацийСрезПоследних
	|		ПО ОборотыДтКт.СубконтоКт2 = РаботникиОрганизацийСрезПоследних.Сотрудник.Физлицо
	|ГДЕ
	|	ОборотыДтКт.СубконтоКт1.ВидРБП В(&ВидРБП)
	|	И ОборотыДтКт.СуммаНУОборотКт <> 0
	|
	|СГРУППИРОВАТЬ ПО
	|	ОборотыДтКт.СубконтоКт1,
	|	ОборотыДтКт.СубконтоКт2,
	|	ОборотыДтКт.Период,
	|	ОборотыДтКт.СубконтоКт2.Код
	|
	|УПОРЯДОЧИТЬ ПО
	|	ДатаОперации,
	|	Работник";

	Результат = Запрос.Выполнить().Выбрать();

	ОбластьПодвал        = Макет.ПолучитьОбласть("Подвал");
	ОбластьШапкаТаблицы  = Макет.ПолучитьОбласть("ШапкаТаблицы");
	ОбластьСтрока        = Макет.ПолучитьОбласть("Строка");

	ДокументРезультат.Вывести(ОбластьШапкаТаблицы);

	ИтогоCуммаПлатежаПоДолгосрочномуСтрахованию = 0;
	ИтогоСуммаПлатежаПоСтрахованиюНаОплатуМедицинскихРасходов = 0;

	ТаблицаРаботников = Новый ТаблицаЗначений;
	ТаблицаРаботников.Колонки.Добавить("Работник");
	ТаблицаРаботников.Колонки.Добавить("Расходы");
	ТаблицаРаботников.Индексы.Добавить("Работник");

	Пока Результат.Следующий() Цикл

		ОбластьСтрока.Параметры.CуммаПлатежаПоДолгосрочномуСтрахованию               = 0;
		ОбластьСтрока.Параметры.СуммаПлатежаПоСтрахованиюНаОплатуМедицинскихРасходов = 0;
		ОбластьСтрока.Параметры.СуммаПлатежаПоСтрахованиюНаСлучайСмерти              = 0;

		Если Результат.РБП.ВидРБП = Страхование1 Тогда

			ОбластьСтрока.Параметры.CуммаПлатежаПоДолгосрочномуСтрахованию = Результат.Сумма;
			ИтогоCуммаПлатежаПоДолгосрочномуСтрахованию = ИтогоCуммаПлатежаПоДолгосрочномуСтрахованию + Результат.Сумма;

		ИначеЕсли Результат.РБП.ВидРБП = Страхование2 Тогда

			ОбластьСтрока.Параметры.СуммаПлатежаПоСтрахованиюНаОплатуМедицинскихРасходов = Результат.Сумма;
			ИтогоСуммаПлатежаПоСтрахованиюНаОплатуМедицинскихРасходов = ИтогоСуммаПлатежаПоСтрахованиюНаОплатуМедицинскихРасходов + Результат.Сумма;

		ИначеЕсли Результат.РБП.ВидРБП = Страхование3 Тогда

			ОбластьСтрока.Параметры.СуммаПлатежаПоСтрахованиюНаСлучайСмерти = Результат.Сумма;
			СтрокаРаботника = ТаблицаРаботников.Найти(Результат.Работник, "Работник");
			Норма = ?(Результат.РБП.ДатаНачалаСписания < '20080101', 10000, 15000);

			Если СтрокаРаботника = Неопределено Тогда

				СтрокаРаботника = ТаблицаРаботников.Добавить();
				СтрокаРаботника.Работник = Результат.Работник;
				СтрокаРаботника.Расходы = Мин(Результат.Сумма, Норма);

			Иначе

				СтрокаРаботника.Расходы = Мин(СтрокаРаботника.Расходы + Результат.Сумма, Норма);
			КонецЕсли;

		КонецЕсли;

		ОбластьСтрока.Параметры.ДатаФормированияЗаписи = Результат.ДатаОперации;
		ОбластьСтрока.Параметры.Работник               = Строка(Результат.Работник) + " таб.№ " + Результат.ТабельныйНомер;
		ДокументРезультат.Вывести(ОбластьСтрока);

	КонецЦикла;

	СтруктураЛиц = РегламентированнаяОтчетность.ОтветственныеЛицаОрганизаций(Организация, ДатаКон);

	ОбластьПодвал.Параметры.ИтогоCуммаПлатежаПоДолгосрочномуСтрахованию = ИтогоCуммаПлатежаПоДолгосрочномуСтрахованию;
	ОбластьПодвал.Параметры.ИтогоСуммаПлатежаПоСтрахованиюНаОплатуМедицинскихРасходов = ИтогоСуммаПлатежаПоСтрахованиюНаОплатуМедицинскихРасходов;
	ОбластьПодвал.Параметры.ИтогоСуммаПлатежаПоСтрахованиюНаСлучайСмерти = ТаблицаРаботников.Итог("Расходы");

	ОбластьПодвал.Параметры.ОтветственныйЗаРегистры = СтруктураЛиц.ОтветственныйЗаРегистры;
	ДокументРезультат.Вывести(ОбластьПодвал);

КонецПроцедуры // СформироватьОтчет

////////////////////////////////////////////////////////////////////////////////
// ОПЕРАТОРЫ ОСНОВНОЙ ПРОГРАММЫ
// 

НП = Новый НастройкаПериода;

#КонецЕсли
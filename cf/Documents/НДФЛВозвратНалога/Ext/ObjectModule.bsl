﻿////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

// Выполняет расчет налога для указанного списка физлиц 
Процедура Рассчитать() Экспорт

	Запрос = Новый Запрос;
	
	ЭтоЮрЛицо = Организация.ЮрФизЛицо <> Перечисления.ЮрФизЛицо.ФизЛицо;
	Запрос.УстановитьПараметр("ГоловнаяОрганизация", ОбщегоНазначения.ГоловнаяОрганизация(Организация));
	Запрос.УстановитьПараметр("ДатаДокумента", Дата);
	Запрос.УстановитьПараметр("МесяцНалоговогоПериода", КонецМесяца(МесяцНалоговогоПериода));
	Запрос.УстановитьПараметр("ДокументСсылка", Ссылка);
	Запрос.УстановитьПараметр("Ставка13", Перечисления.НДФЛСтавкиНалогообложенияРезидента.Ставка13);
	Запрос.УстановитьПараметр("Ставка09", Перечисления.НДФЛСтавкиНалогообложенияРезидента.Ставка09);
	Запрос.УстановитьПараметр("Ставка35", Перечисления.НДФЛСтавкиНалогообложенияРезидента.Ставка35);
	
	// Выбор сальдо на дату документа с учетом всех "МесяцевНалоговогоПериода" < МесяцНалоговогоПериода
	// Интересует только отрицательное сальдо по налогу, т.е. когда удержано больше чем начислено
	
	Если ЭтоЮрЛицо Тогда
		
		Запрос.УстановитьПараметр("ПустойКодПоОКАТО","");
		Запрос.УстановитьПараметр("ПустойКПП","");
		
		Запрос.Текст = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	ВЫБОР
		|		КОГДА СальдоПоСтавкам.СальдоПоСтавке13 < 0
		|			ТОГДА -СальдоПоСтавкам.СальдоПоСтавке13
		|		ИНАЧЕ 0
		|	КОНЕЦ КАК СуммаВозвратаПоСтавке13,
		|	ВЫБОР
		|		КОГДА СальдоПоСтавкам.СальдоПоСтавке09 < 0
		|			ТОГДА -СальдоПоСтавкам.СальдоПоСтавке09
		|		ИНАЧЕ 0
		|	КОНЕЦ КАК СуммаВозвратаПоСтавке09,
		|	ВЫБОР
		|		КОГДА СальдоПоСтавкам.СальдоПоСтавке35 < 0
		|			ТОГДА -СальдоПоСтавкам.СальдоПоСтавке35
		|		ИНАЧЕ 0
		|	КОНЕЦ КАК СуммаВозвратаПоСтавке35,
		|	НДФЛВозвратНалогаРаботникиОрганизации.НомерСтроки КАК НомерСтроки,
		|	НДФЛВозвратНалогаРаботникиОрганизации.ФизЛицо,
		|	НДФЛВозвратНалогаРаботникиОрганизации.КодПоОКАТО,
		|	НДФЛВозвратНалогаРаботникиОрганизации.КПП
		|ИЗ
		|	Документ.НДФЛВозвратНалога.РаботникиОрганизации КАК НДФЛВозвратНалогаРаботникиОрганизации
		|		ЛЕВОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
		|			НДФЛРасчетыСБюджетом.ФизЛицо КАК ФизЛицо,
		|			СУММА(ВЫБОР
		|					КОГДА НДФЛРасчетыСБюджетом.СтавкаНалогообложенияРезидента = &Ставка13
		|						ТОГДА ВЫБОР
		|								КОГДА НДФЛРасчетыСБюджетом.ВидДвижения = ЗНАЧЕНИЕ(ВидДвиженияНакопления.Приход)
		|									ТОГДА НДФЛРасчетыСБюджетом.Налог
		|								ИНАЧЕ -НДФЛРасчетыСБюджетом.Налог
		|							КОНЕЦ
		|					ИНАЧЕ 0
		|				КОНЕЦ) КАК СальдоПоСтавке13,
		|			СУММА(ВЫБОР
		|					КОГДА НДФЛРасчетыСБюджетом.СтавкаНалогообложенияРезидента = &Ставка09
		|						ТОГДА ВЫБОР
		|								КОГДА НДФЛРасчетыСБюджетом.ВидДвижения = ЗНАЧЕНИЕ(ВидДвиженияНакопления.Приход)
		|									ТОГДА НДФЛРасчетыСБюджетом.Налог
		|								ИНАЧЕ -НДФЛРасчетыСБюджетом.Налог
		|							КОНЕЦ
		|					ИНАЧЕ 0
		|				КОНЕЦ) КАК СальдоПоСтавке09,
		|			СУММА(ВЫБОР
		|					КОГДА НДФЛРасчетыСБюджетом.СтавкаНалогообложенияРезидента = &Ставка35
		|						ТОГДА ВЫБОР
		|								КОГДА НДФЛРасчетыСБюджетом.ВидДвижения = ЗНАЧЕНИЕ(ВидДвиженияНакопления.Приход)
		|									ТОГДА НДФЛРасчетыСБюджетом.Налог
		|								ИНАЧЕ -НДФЛРасчетыСБюджетом.Налог
		|							КОНЕЦ
		|					ИНАЧЕ 0
		|				КОНЕЦ) КАК СальдоПоСтавке35,
		|			ВЫБОР
		|				КОГДА НДФЛРасчетыСБюджетом.КодПоОКАТО <> &ПустойКодПоОКАТО
		|					ТОГДА НДФЛРасчетыСБюджетом.КодПоОКАТО
		|				КОГДА ЕСТЬNULL(НДФЛРасчетыСБюджетом.ПодразделениеОрганизации.КодПоОКАТО, &ПустойКодПоОКАТО) <> &ПустойКодПоОКАТО
		|					ТОГДА НДФЛРасчетыСБюджетом.ПодразделениеОрганизации.КодПоОКАТО
		|				ИНАЧЕ ЕСТЬNULL(НДФЛРасчетыСБюджетом.ОбособленноеПодразделение.КодПоОКАТО, &ПустойКодПоОКАТО)
		|			КОНЕЦ КАК КодПоОКАТО,
		|			ВЫБОР
		|				КОГДА НДФЛРасчетыСБюджетом.КПП <> &ПустойКПП
		|					ТОГДА НДФЛРасчетыСБюджетом.КПП
		|				КОГДА ЕСТЬNULL(НДФЛРасчетыСБюджетом.ПодразделениеОрганизации.КПП, &ПустойКПП) <> &ПустойКПП
		|					ТОГДА НДФЛРасчетыСБюджетом.ПодразделениеОрганизации.КПП
		|				ИНАЧЕ ЕСТЬNULL(НДФЛРасчетыСБюджетом.ОбособленноеПодразделение.КПП, &ПустойКПП)
		|			КОНЕЦ КАК КПП
		|		ИЗ
		|			РегистрНакопления.НДФЛРасчетыСБюджетом КАК НДФЛРасчетыСБюджетом
		|				ВНУТРЕННЕЕ СОЕДИНЕНИЕ (ВЫБРАТЬ РАЗЛИЧНЫЕ
		|					НДФЛВозвратНалогаРаботникиОрганизации.ФизЛицо КАК ФизЛицо
		|				ИЗ
		|					Документ.НДФЛВозвратНалога.РаботникиОрганизации КАК НДФЛВозвратНалогаРаботникиОрганизации
		|				ГДЕ
		|					НДФЛВозвратНалогаРаботникиОрганизации.Ссылка = &ДокументСсылка) КАК НДФЛВозвратНалогаРаботникиОрганизации
		|				ПО НДФЛВозвратНалогаРаботникиОрганизации.ФизЛицо = НДФЛРасчетыСБюджетом.ФизЛицо
		|		ГДЕ
		|			НДФЛРасчетыСБюджетом.МесяцНалоговогоПериода <= &МесяцНалоговогоПериода
		|			И НДФЛРасчетыСБюджетом.Организация = &ГоловнаяОрганизация
		|			И НДФЛРасчетыСБюджетом.Период <= &ДатаДокумента
		|		
		|		СГРУППИРОВАТЬ ПО
		|			ВЫБОР
		|				КОГДА НДФЛРасчетыСБюджетом.КПП <> &ПустойКПП
		|					ТОГДА НДФЛРасчетыСБюджетом.КПП
		|				КОГДА ЕСТЬNULL(НДФЛРасчетыСБюджетом.ПодразделениеОрганизации.КПП, &ПустойКПП) <> &ПустойКПП
		|					ТОГДА НДФЛРасчетыСБюджетом.ПодразделениеОрганизации.КПП
		|				ИНАЧЕ ЕСТЬNULL(НДФЛРасчетыСБюджетом.ОбособленноеПодразделение.КПП, &ПустойКПП)
		|			КОНЕЦ,
		|			ВЫБОР
		|				КОГДА НДФЛРасчетыСБюджетом.КодПоОКАТО <> &ПустойКодПоОКАТО
		|					ТОГДА НДФЛРасчетыСБюджетом.КодПоОКАТО
		|				КОГДА ЕСТЬNULL(НДФЛРасчетыСБюджетом.ПодразделениеОрганизации.КодПоОКАТО, &ПустойКодПоОКАТО) <> &ПустойКодПоОКАТО
		|					ТОГДА НДФЛРасчетыСБюджетом.ПодразделениеОрганизации.КодПоОКАТО
		|				ИНАЧЕ ЕСТЬNULL(НДФЛРасчетыСБюджетом.ОбособленноеПодразделение.КодПоОКАТО, &ПустойКодПоОКАТО)
		|			КОНЕЦ,
		|			НДФЛРасчетыСБюджетом.ФизЛицо) КАК СальдоПоСтавкам
		|		ПО НДФЛВозвратНалогаРаботникиОрганизации.ФизЛицо = СальдоПоСтавкам.ФизЛицо
		|			И НДФЛВозвратНалогаРаботникиОрганизации.КодПоОКАТО = СальдоПоСтавкам.КодПоОКАТО
		|			И НДФЛВозвратНалогаРаботникиОрганизации.КПП = СальдоПоСтавкам.КПП
		|			И (СальдоПоСтавкам.СальдоПоСтавке13 < 0
		|				ИЛИ СальдоПоСтавкам.СальдоПоСтавке09 < 0
		|				ИЛИ СальдоПоСтавкам.СальдоПоСтавке35 < 0)
		|ГДЕ
		|	НДФЛВозвратНалогаРаботникиОрганизации.Ссылка = &ДокументСсылка
		|
		|УПОРЯДОЧИТЬ ПО
		|	НомерСтроки";
		
	Иначе
		
		Запрос.Текст = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	СальдоПоСтавкам.НомерСтроки КАК НомерСтроки,
		|	СальдоПоСтавкам.ФизЛицо,
		|	СУММА(СальдоПоСтавкам.СальдоПоСтавке13) КАК СуммаВозвратаПоСтавке13,
		|	СУММА(СальдоПоСтавкам.СальдоПоСтавке09) КАК СуммаВозвратаПоСтавке09,
		|	СУММА(СальдоПоСтавкам.СальдоПоСтавке35) КАК СуммаВозвратаПоСтавке35
		|ИЗ
		|	(ВЫБРАТЬ
		|		ТЧРаботникиОрганизации.НомерСтроки КАК НомерСтроки,
		|		ТЧРаботникиОрганизации.ФизЛицо КАК ФизЛицо,
		|		НДФЛРасчетыСБюджетомОстатки.МесяцНалоговогоПериода КАК МесяцНалоговогоПериода,
		|		ВЫБОР
		|			КОГДА НДФЛРасчетыСБюджетомОстатки.СтавкаНалогообложенияРезидента = &Ставка13
		|				ТОГДА -НДФЛРасчетыСБюджетомОстатки.НалогОстаток
		|			ИНАЧЕ 0
		|		КОНЕЦ КАК СальдоПоСтавке13,
		|		ВЫБОР
		|			КОГДА НДФЛРасчетыСБюджетомОстатки.СтавкаНалогообложенияРезидента = &Ставка09
		|				ТОГДА -НДФЛРасчетыСБюджетомОстатки.НалогОстаток
		|			ИНАЧЕ 0
		|		КОНЕЦ КАК СальдоПоСтавке09,
		|		ВЫБОР
		|			КОГДА НДФЛРасчетыСБюджетомОстатки.СтавкаНалогообложенияРезидента = &Ставка35
		|				ТОГДА -НДФЛРасчетыСБюджетомОстатки.НалогОстаток
		|			ИНАЧЕ 0
		|		КОНЕЦ КАК СальдоПоСтавке35
		|	ИЗ
		|		Документ.НДФЛВозвратНалога.РаботникиОрганизации КАК ТЧРаботникиОрганизации
		|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.НДФЛРасчетыСБюджетом.Остатки(
		|			&ДатаДокумента,
		|			Организация = &ГоловнаяОрганизация
		|				И МесяцНалоговогоПериода <= &МесяцНалоговогоПериода
		|				И ФизЛицо В
		|					(ВЫБРАТЬ
		|						ТЧ.ФизЛицо
		|					ИЗ
		|						Документ.НДФЛВозвратНалога.РаботникиОрганизации КАК ТЧ
		|					ГДЕ
		|						ТЧ.Ссылка = &ДокументСсылка)) КАК НДФЛРасчетыСБюджетомОстатки
		|			ПО ТЧРаботникиОрганизации.ФизЛицо = НДФЛРасчетыСБюджетомОстатки.ФизЛицо
		|	ГДЕ
		|		ТЧРаботникиОрганизации.Ссылка = &ДокументСсылка
		|		И НДФЛРасчетыСБюджетомОстатки.НалогОстаток < 0) КАК СальдоПоСтавкам
		|
		|СГРУППИРОВАТЬ ПО
		|	СальдоПоСтавкам.НомерСтроки,
		|	СальдоПоСтавкам.ФизЛицо
		|
		|УПОРЯДОЧИТЬ ПО
		|	НомерСтроки";
		
	КонецЕсли;
				   
	РаботникиОрганизации.Загрузить(Запрос.Выполнить().Выгрузить());
	
КонецПроцедуры

// Заполняет табличную часть документа отпусками по графику отпусков
//
// Параметры
//  ДатаНачала, ДатаОкончания – даты начала и окончания 
//								просмотра графика отпусков	
//
Процедура Автозаполнение() Экспорт
	
	Запрос = Новый Запрос;
	
	ЭтоЮрЛицо = Организация.ЮрФизЛицо <> Перечисления.ЮрФизЛицо.ФизЛицо;
	Запрос.УстановитьПараметр("ГоловнаяОрганизация",	ОбщегоНазначения.ГоловнаяОрганизация(Организация));
	Запрос.УстановитьПараметр("МесяцНалоговогоПериода",	КонецМесяца(МесяцНалоговогоПериода));
	Запрос.УстановитьПараметр("ДатаДокумента",			Дата);
	Запрос.УстановитьПараметр("Ставка13",				Перечисления.НДФЛСтавкиНалогообложенияРезидента.Ставка13);
	Запрос.УстановитьПараметр("Ставка09",				Перечисления.НДФЛСтавкиНалогообложенияРезидента.Ставка09);
	Запрос.УстановитьПараметр("Ставка35",				Перечисления.НДФЛСтавкиНалогообложенияРезидента.Ставка35);
	Запрос.УстановитьПараметр("парамПриход",			ВидДвиженияНакопления.Приход);
	
	Если ЭтоЮрЛицо Тогда
		Запрос.УстановитьПараметр("ПустойКодПоОКАТО","");
		Запрос.УстановитьПараметр("ПустойКПП","");
		Запрос.Текст = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	СальдоПоСтавкам.ФизЛицо,
		|	СальдоПоСтавкам.КодПоОКАТО,
		|	СальдоПоСтавкам.КПП,
		|	ВЫБОР
		|		КОГДА СальдоПоСтавкам.СальдоПоСтавке13 < 0
		|			ТОГДА -СальдоПоСтавкам.СальдоПоСтавке13
		|		ИНАЧЕ 0
		|	КОНЕЦ КАК СуммаВозвратаПоСтавке13,
		|	ВЫБОР
		|		КОГДА СальдоПоСтавкам.СальдоПоСтавке09 < 0
		|			ТОГДА -СальдоПоСтавкам.СальдоПоСтавке09
		|		ИНАЧЕ 0
		|	КОНЕЦ КАК СуммаВозвратаПоСтавке09,
		|	ВЫБОР
		|		КОГДА СальдоПоСтавкам.СальдоПоСтавке35 < 0
		|			ТОГДА -СальдоПоСтавкам.СальдоПоСтавке35
		|		ИНАЧЕ 0
		|	КОНЕЦ КАК СуммаВозвратаПоСтавке35
		|ИЗ
		|	(ВЫБРАТЬ
		|		НДФЛРасчетыСБюджетом.ФизЛицо КАК ФизЛицо,
		|		СУММА(ВЫБОР
		|				КОГДА НДФЛРасчетыСБюджетом.СтавкаНалогообложенияРезидента = &Ставка13
		|					ТОГДА ВЫБОР
		|							КОГДА НДФЛРасчетыСБюджетом.ВидДвижения = &парамПриход
		|								ТОГДА НДФЛРасчетыСБюджетом.Налог
		|							ИНАЧЕ -НДФЛРасчетыСБюджетом.Налог
		|						КОНЕЦ
		|				ИНАЧЕ 0
		|			КОНЕЦ) КАК СальдоПоСтавке13,
		|		СУММА(ВЫБОР
		|				КОГДА НДФЛРасчетыСБюджетом.СтавкаНалогообложенияРезидента = &Ставка09
		|					ТОГДА ВЫБОР
		|							КОГДА НДФЛРасчетыСБюджетом.ВидДвижения = &парамПриход
		|								ТОГДА НДФЛРасчетыСБюджетом.Налог
		|							ИНАЧЕ -НДФЛРасчетыСБюджетом.Налог
		|						КОНЕЦ
		|				ИНАЧЕ 0
		|			КОНЕЦ) КАК СальдоПоСтавке09,
		|		СУММА(ВЫБОР
		|				КОГДА НДФЛРасчетыСБюджетом.СтавкаНалогообложенияРезидента = &Ставка35
		|					ТОГДА ВЫБОР
		|							КОГДА НДФЛРасчетыСБюджетом.ВидДвижения = &парамПриход
		|								ТОГДА НДФЛРасчетыСБюджетом.Налог
		|							ИНАЧЕ -НДФЛРасчетыСБюджетом.Налог
		|						КОНЕЦ
		|				ИНАЧЕ 0
		|			КОНЕЦ) КАК СальдоПоСтавке35,
		|		ВЫБОР
		|			КОГДА НДФЛРасчетыСБюджетом.КодПоОКАТО <> &ПустойКодПоОКАТО
		|				ТОГДА НДФЛРасчетыСБюджетом.КодПоОКАТО
		|			КОГДА ЕСТЬNULL(НДФЛРасчетыСБюджетом.ПодразделениеОрганизации.КодПоОКАТО, &ПустойКодПоОКАТО) <> &ПустойКодПоОКАТО
		|				ТОГДА НДФЛРасчетыСБюджетом.ПодразделениеОрганизации.КодПоОКАТО
		|			ИНАЧЕ ЕСТЬNULL(НДФЛРасчетыСБюджетом.ОбособленноеПодразделение.КодПоОКАТО, &ПустойКодПоОКАТО)
		|		КОНЕЦ КАК КодПоОКАТО,
		|		ВЫБОР
		|			КОГДА НДФЛРасчетыСБюджетом.КПП <> &ПустойКПП
		|				ТОГДА НДФЛРасчетыСБюджетом.КПП
		|			КОГДА ЕСТЬNULL(НДФЛРасчетыСБюджетом.ПодразделениеОрганизации.КПП, &ПустойКПП) <> &ПустойКПП
		|				ТОГДА НДФЛРасчетыСБюджетом.ПодразделениеОрганизации.КПП
		|			ИНАЧЕ ЕСТЬNULL(НДФЛРасчетыСБюджетом.ОбособленноеПодразделение.КПП, &ПустойКПП)
		|		КОНЕЦ КАК КПП
		|	ИЗ
		|		РегистрНакопления.НДФЛРасчетыСБюджетом КАК НДФЛРасчетыСБюджетом
		|	ГДЕ
		|		НДФЛРасчетыСБюджетом.МесяцНалоговогоПериода <= &МесяцНалоговогоПериода
		|		И НДФЛРасчетыСБюджетом.Организация = &ГоловнаяОрганизация
		|		И НДФЛРасчетыСБюджетом.Период <= &ДатаДокумента
		|	
		|	СГРУППИРОВАТЬ ПО
		|		НДФЛРасчетыСБюджетом.ФизЛицо,
		|		ВЫБОР
		|			КОГДА НДФЛРасчетыСБюджетом.КПП <> &ПустойКПП
		|				ТОГДА НДФЛРасчетыСБюджетом.КПП
		|			КОГДА ЕСТЬNULL(НДФЛРасчетыСБюджетом.ПодразделениеОрганизации.КПП, &ПустойКПП) <> &ПустойКПП
		|				ТОГДА НДФЛРасчетыСБюджетом.ПодразделениеОрганизации.КПП
		|			ИНАЧЕ ЕСТЬNULL(НДФЛРасчетыСБюджетом.ОбособленноеПодразделение.КПП, &ПустойКПП)
		|		КОНЕЦ,
		|		ВЫБОР
		|			КОГДА НДФЛРасчетыСБюджетом.КодПоОКАТО <> &ПустойКодПоОКАТО
		|				ТОГДА НДФЛРасчетыСБюджетом.КодПоОКАТО
		|			КОГДА ЕСТЬNULL(НДФЛРасчетыСБюджетом.ПодразделениеОрганизации.КодПоОКАТО, &ПустойКодПоОКАТО) <> &ПустойКодПоОКАТО
		|				ТОГДА НДФЛРасчетыСБюджетом.ПодразделениеОрганизации.КодПоОКАТО
		|			ИНАЧЕ ЕСТЬNULL(НДФЛРасчетыСБюджетом.ОбособленноеПодразделение.КодПоОКАТО, &ПустойКодПоОКАТО)
		|		КОНЕЦ) КАК СальдоПоСтавкам
		|ГДЕ
		|	(СальдоПоСтавкам.СальдоПоСтавке13 < 0
		|			ИЛИ СальдоПоСтавкам.СальдоПоСтавке09 < 0
		|			ИЛИ СальдоПоСтавкам.СальдоПоСтавке35 < 0)";
		
	Иначе
		
		Запрос.Текст = 
		"ВЫБРАТЬ РАЗРЕШЕННЫЕ
		|	СальдоПоСтавкам.ФизЛицо,
		|	ВЫБОР
		|		КОГДА СальдоПоСтавкам.СальдоПоСтавке13 < 0
		|			ТОГДА -СальдоПоСтавкам.СальдоПоСтавке13
		|		ИНАЧЕ 0
		|	КОНЕЦ КАК СуммаВозвратаПоСтавке13,
		|	ВЫБОР
		|		КОГДА СальдоПоСтавкам.СальдоПоСтавке09 < 0
		|			ТОГДА -СальдоПоСтавкам.СальдоПоСтавке09
		|		ИНАЧЕ 0
		|	КОНЕЦ КАК СуммаВозвратаПоСтавке09,
		|	ВЫБОР
		|		КОГДА СальдоПоСтавкам.СальдоПоСтавке35 < 0
		|			ТОГДА -СальдоПоСтавкам.СальдоПоСтавке35
		|		ИНАЧЕ 0
		|	КОНЕЦ КАК СуммаВозвратаПоСтавке35
		|ИЗ
		|	(ВЫБРАТЬ
		|		НДФЛРасчетыСБюджетом.ФизЛицо КАК ФизЛицо,
		|		СУММА(ВЫБОР
		|				КОГДА НДФЛРасчетыСБюджетом.СтавкаНалогообложенияРезидента = &Ставка13
		|					ТОГДА ВЫБОР
		|							КОГДА НДФЛРасчетыСБюджетом.ВидДвижения = &парамПриход
		|								ТОГДА НДФЛРасчетыСБюджетом.Налог
		|							ИНАЧЕ -НДФЛРасчетыСБюджетом.Налог
		|						КОНЕЦ
		|				ИНАЧЕ 0
		|			КОНЕЦ) КАК СальдоПоСтавке13,
		|		СУММА(ВЫБОР
		|				КОГДА НДФЛРасчетыСБюджетом.СтавкаНалогообложенияРезидента = &Ставка09
		|					ТОГДА ВЫБОР
		|							КОГДА НДФЛРасчетыСБюджетом.ВидДвижения = &парамПриход
		|								ТОГДА НДФЛРасчетыСБюджетом.Налог
		|							ИНАЧЕ -НДФЛРасчетыСБюджетом.Налог
		|						КОНЕЦ
		|				ИНАЧЕ 0
		|			КОНЕЦ) КАК СальдоПоСтавке09,
		|		СУММА(ВЫБОР
		|				КОГДА НДФЛРасчетыСБюджетом.СтавкаНалогообложенияРезидента = &Ставка35
		|					ТОГДА ВЫБОР
		|							КОГДА НДФЛРасчетыСБюджетом.ВидДвижения = &парамПриход
		|								ТОГДА НДФЛРасчетыСБюджетом.Налог
		|							ИНАЧЕ -НДФЛРасчетыСБюджетом.Налог
		|						КОНЕЦ
		|				ИНАЧЕ 0
		|			КОНЕЦ) КАК СальдоПоСтавке35
		|	ИЗ
		|		РегистрНакопления.НДФЛРасчетыСБюджетом КАК НДФЛРасчетыСБюджетом
		|	ГДЕ
		|		НДФЛРасчетыСБюджетом.МесяцНалоговогоПериода <= &МесяцНалоговогоПериода
		|		И НДФЛРасчетыСБюджетом.Организация = &ГоловнаяОрганизация
		|		И НДФЛРасчетыСБюджетом.Период <= &ДатаДокумента
		|	
		|	СГРУППИРОВАТЬ ПО
		|		НДФЛРасчетыСБюджетом.ФизЛицо) КАК СальдоПоСтавкам
		|ГДЕ
		|	(СальдоПоСтавкам.СальдоПоСтавке13 < 0
		|			ИЛИ СальдоПоСтавкам.СальдоПоСтавке09 < 0
		|			ИЛИ СальдоПоСтавкам.СальдоПоСтавке35 < 0)";
		
	КонецЕсли;
	
	РаботникиОрганизации.Загрузить(Запрос.Выполнить().Выгрузить());
	
КонецПроцедуры // Автозаполнение()

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

// Формирует запрос по шапке документа
//
// Параметры: 
//  Режим - режим проведения
//
// Возвращаемое значение:
//  Результат запроса
//
Функция СформироватьЗапросПоШапке(Режим)

	Запрос = Новый Запрос;

	// Установим параметры запроса
	Запрос.УстановитьПараметр("ДокументСсылка" , Ссылка);

	Запрос.Текст = 
	"ВЫБРАТЬ
	|	НДФЛВозвратНалога.Дата,
	|	НДФЛВозвратНалога.Ссылка,
	|	НДФЛВозвратНалога.МесяцНалоговогоПериода,
	|	НДФЛВозвратНалога.Организация,
	|	ВЫБОР
	|		КОГДА НДФЛВозвратНалога.Организация.ГоловнаяОрганизация = ЗНАЧЕНИЕ(Справочник.Организации.ПустаяСсылка)
	|			ТОГДА НДФЛВозвратНалога.Организация
	|		ИНАЧЕ НДФЛВозвратНалога.Организация.ГоловнаяОрганизация
	|	КОНЕЦ КАК ГоловнаяОрганизация
	|ИЗ
	|	Документ.НДФЛВозвратНалога КАК НДФЛВозвратНалога
	|ГДЕ
	|	НДФЛВозвратНалога.Ссылка = &ДокументСсылка";

	Возврат Запрос.Выполнить();

КонецФункции // СформироватьЗапросПоШапке()

// Формирует запрос по табличной части документам
//
// Параметры: 
//  Режим        - режим проведения.
//
// Возвращаемое значение:
//  Результат запроса.
//
Функция СформироватьЗапросПоРаботникиОрганизации(Режим)

	Запрос = Новый Запрос;

	// Установим параметры запроса
	Запрос.УстановитьПараметр("ДокументСсылка" , Ссылка);
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	НДФЛВозвратНалогаРаботникиОрганизации.НомерСтроки,
	|	НДФЛВозвратНалогаРаботникиОрганизации.ФизЛицо,
	|	НДФЛВозвратНалогаРаботникиОрганизации.СуммаВозвратаПоСтавке13,
	|	НДФЛВозвратНалогаРаботникиОрганизации.СуммаВозвратаПоСтавке09,
	|	НДФЛВозвратНалогаРаботникиОрганизации.СуммаВозвратаПоСтавке35,
	|	НДФЛВозвратНалогаРаботникиОрганизации.КодПоОКАТО,
	|	НДФЛВозвратНалогаРаботникиОрганизации.КПП
	|ИЗ
	|	Документ.НДФЛВозвратНалога.РаботникиОрганизации КАК НДФЛВозвратНалогаРаботникиОрганизации
	|ГДЕ
	|	НДФЛВозвратНалогаРаботникиОрганизации.Ссылка = &ДокументСсылка";

	Возврат Запрос.Выполнить();

КонецФункции // СформироватьЗапросПоШапке()

// Проверяет правильность заполнения шапки документа.
// Если какой-то из реквизитов шапки, влияющий на проведение не заполнен или
// заполнен не корректно, то выставляется флаг отказа в проведении.
// Проверка выполняется по выборке из результата запроса по шапке,
// все проверяемые реквизиты должны быть включены в выборку по шапке.
//
// Параметры: 
//  ВыборкаПоШапкеДокумента	- выборка из результата запроса по шапке документа,
//  Отказ 		 - флаг отказа в проведении,
//	Заголовок	 - Заголовок для сообщений об ошибках проведения.
//
Процедура ПроверитьЗаполнениеШапки(ВыборкаПоШапкеДокумента, Отказ, Заголовок)

	Если НЕ ЗначениеЗаполнено(ВыборкаПоШапкеДокумента.Организация) Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Не указана организация!", Отказ, Заголовок);
	КонецЕсли;
	Если НЕ ЗначениеЗаполнено(ВыборкаПоШапкеДокумента.МесяцНалоговогоПериода) Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Не указан период, за который возвращается налог!", Отказ, Заголовок);
	КонецЕсли;

КонецПроцедуры // ПроверитьЗаполнениеШапки()

// Проверяет правильность заполнения строки документа.
Процедура ПроверитьЗаполнениеСтрокиРаботникиОрганизации(ВыборкаПоРаботникиОрганизации, Отказ, Заголовок)

		НачалоСообщения = "В строке № """+ СокрЛП(ВыборкаПоРаботникиОрганизации.НомерСтроки) +
									""" табл. части ""Работники организации"": ";
									
		Если НЕ ЗначениеЗаполнено(ВыборкаПоРаботникиОрганизации.ФизЛицо) Тогда
			ОбщегоНазначения.СообщитьОбОшибке(НачалоСообщения + "не указано физическое лицо!", Отказ, Заголовок);
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(ВыборкаПоРаботникиОрганизации.СуммаВозвратаПоСтавке13 + ВыборкаПоРаботникиОрганизации.СуммаВозвратаПоСтавке09 + ВыборкаПоРаботникиОрганизации.СуммаВозвратаПоСтавке35) Тогда
			ОбщегоНазначения.СообщитьОбОшибке(НачалоСообщения + "не указаны суммы возврата налога!", Отказ, Заголовок);
		КонецЕсли;
	
КонецПроцедуры // ПроверитьЗаполнениеСтрокиРаботникиОрганизации()

// По строке выборки результата запроса по документу формируем движения по регистрам
//
// Параметры: 
//  ВыборкаПоШапкеДокумента                  - выборка из результата запроса по шапке документа
//
// Возвращаемое значение:
//  Нет.
//
Процедура ДобавитьСтрокуВДвиженияПоРегистрамНакопления(ВыборкаПоШапкеДокумента, ВыборкаПоТЧ)
	
	// Проведем возврат как отрицательный расход (отрицательное удержание налога) отдельно для каждой ставки
	
	Если ВыборкаПоТЧ.СуммаВозвратаПоСтавке13 <> 0 Тогда
		Движение = Движения.НДФЛКЗачету.Добавить();
		// Свойства
		Движение.Период                 = ВыборкаПоШапкеДокумента.Дата;
		Движение.ВидДвижения			= ВидДвиженияНакопления.Расход;
		// Измерения
		Движение.Организация			        = ВыборкаПоШапкеДокумента.Организация;
		Движение.ФизЛицо                        = ВыборкаПоТЧ.ФизЛицо;
		Движение.СтавкаНалогообложенияРезидента = Перечисления.НДФЛСтавкиНалогообложенияРезидента.Ставка13;
		
		// Ресурсы
		Движение.СуммаНДФЛКЗачету = ВыборкаПоТЧ.СуммаВозвратаПоСтавке13;
	КонецЕсли;
	
	Если ВыборкаПоТЧ.СуммаВозвратаПоСтавке09 <> 0 Тогда
		Движение = Движения.НДФЛКЗачету.Добавить();
		// Свойства
		Движение.Период                 = ВыборкаПоШапкеДокумента.Дата;
		Движение.ВидДвижения			= ВидДвиженияНакопления.Расход;
		// Измерения
		Движение.Организация			        = ВыборкаПоШапкеДокумента.Организация;
		Движение.ФизЛицо                        = ВыборкаПоТЧ.ФизЛицо;
		Движение.СтавкаНалогообложенияРезидента = Перечисления.НДФЛСтавкиНалогообложенияРезидента.Ставка09;
		
		// Ресурсы
		Движение.СуммаНДФЛКЗачету = ВыборкаПоТЧ.СуммаВозвратаПоСтавке09;
	КонецЕсли;
	
	Если ВыборкаПоТЧ.СуммаВозвратаПоСтавке35 <> 0 Тогда
		Движение = Движения.НДФЛКЗачету.Добавить();
		// Свойства
		Движение.Период                 = ВыборкаПоШапкеДокумента.Дата;
		Движение.ВидДвижения			= ВидДвиженияНакопления.Расход;
		// Измерения
		Движение.Организация			        = ВыборкаПоШапкеДокумента.Организация;
		Движение.ФизЛицо                        = ВыборкаПоТЧ.ФизЛицо;
		Движение.СтавкаНалогообложенияРезидента = Перечисления.НДФЛСтавкиНалогообложенияРезидента.Ставка35;
		
		// Ресурсы
		Движение.СуммаНДФЛКЗачету = ВыборкаПоТЧ.СуммаВозвратаПоСтавке35;
	КонецЕсли;
	
	// Проведем возврат как отрицательный расход (отрицательное удержание налога) отдельно для каждой ставки
	
	Если ВыборкаПоТЧ.СуммаВозвратаПоСтавке13 <> 0 Тогда
		Движение = Движения.НДФЛРасчетыСБюджетом.Добавить();
		// Свойства
		Движение.Период                 = ВыборкаПоШапкеДокумента.Дата;
		Движение.ВидДвижения			= ВидДвиженияНакопления.Расход;
		// Измерения
		Движение.Организация					= ВыборкаПоШапкеДокумента.ГоловнаяОрганизация;
		Движение.ФизЛицо                		= ВыборкаПоТЧ.ФизЛицо;
		Движение.СтавкаНалогообложенияРезидента	= Перечисления.НДФЛСтавкиНалогообложенияРезидента.Ставка13;
		Движение.МесяцНалоговогоПериода      	= ВыборкаПоШапкеДокумента.МесяцНалоговогоПериода;
		// Ресурсы
		Движение.Налог					= - ВыборкаПоТЧ.СуммаВозвратаПоСтавке13; 
		// Реквизиты
		Движение.ОбособленноеПодразделение  = ВыборкаПоШапкеДокумента.Организация;
		Движение.ВидСтроки				= Перечисления.НДФЛРасчетыСБюджетомВидСтроки.ВозвратНалога;
		Движение.КодПоОКАТО				= ВыборкаПоТЧ.КодПоОКАТО; 
		Движение.КПП					= ВыборкаПоТЧ.КПП; 
	КонецЕсли;
	
	Если ВыборкаПоТЧ.СуммаВозвратаПоСтавке09 <> 0 Тогда
		Движение = Движения.НДФЛРасчетыСБюджетом.Добавить();
		// Свойства
		Движение.Период                 = ВыборкаПоШапкеДокумента.Дата;
		Движение.ВидДвижения			= ВидДвиженияНакопления.Расход;
		// Измерения
		Движение.Организация			= ВыборкаПоШапкеДокумента.ГоловнаяОрганизация;
		Движение.ФизЛицо                = ВыборкаПоТЧ.ФизЛицо;
		Движение.СтавкаНалогообложенияРезидента	= Перечисления.НДФЛСтавкиНалогообложенияРезидента.Ставка09;
		Движение.МесяцНалоговогоПериода = ВыборкаПоШапкеДокумента.МесяцНалоговогоПериода;
		// Ресурсы
		Движение.Налог					= - ВыборкаПоТЧ.СуммаВозвратаПоСтавке09; 
		// Реквизиты
		Движение.ОбособленноеПодразделение  = ВыборкаПоШапкеДокумента.Организация;
		Движение.ВидСтроки				= Перечисления.НДФЛРасчетыСБюджетомВидСтроки.ВозвратНалога;
		Движение.КодПоОКАТО				= ВыборкаПоТЧ.КодПоОКАТО; 
		Движение.КПП					= ВыборкаПоТЧ.КПП; 
		Движение.КодДохода				= Справочники.ДоходыНДФЛ.Код1010;
	КонецЕсли;
	
	Если ВыборкаПоТЧ.СуммаВозвратаПоСтавке35 <> 0 Тогда
		Движение = Движения.НДФЛРасчетыСБюджетом.Добавить();
		// Свойства
		Движение.Период                 = ВыборкаПоШапкеДокумента.Дата;
		Движение.ВидДвижения			= ВидДвиженияНакопления.Расход;
		// Измерения
		Движение.Организация					= ВыборкаПоШапкеДокумента.ГоловнаяОрганизация;
		Движение.ФизЛицо                		= ВыборкаПоТЧ.ФизЛицо;
		Движение.СтавкаНалогообложенияРезидента	= Перечисления.НДФЛСтавкиНалогообложенияРезидента.Ставка35;
		Движение.МесяцНалоговогоПериода 		= ВыборкаПоШапкеДокумента.МесяцНалоговогоПериода;
		// Ресурсы
		Движение.Налог					= - ВыборкаПоТЧ.СуммаВозвратаПоСтавке35; 
		// Реквизиты
		Движение.ОбособленноеПодразделение  = ВыборкаПоШапкеДокумента.Организация;
		Движение.ВидСтроки				= Перечисления.НДФЛРасчетыСБюджетомВидСтроки.ВозвратНалога;
		Движение.КодПоОКАТО				= ВыборкаПоТЧ.КодПоОКАТО; 
		Движение.КПП					= ВыборкаПоТЧ.КПП; 
	КонецЕсли;
	
	// Проведем возврат как отрицательный расход (отрицательное удержание налога) отдельно для каждой ставки
	
	Если ВыборкаПоТЧ.СуммаВозвратаПоСтавке13 <> 0 Тогда
		Движение = Движения.ВзаиморасчетыСРаботникамиОрганизаций.Добавить();
		// Свойства
		Движение.Период           				= ВыборкаПоШапкеДокумента.Дата;
		Движение.ВидДвижения					= ВидДвиженияНакопления.Приход;
		// Измерения
		Движение.Организация					= ВыборкаПоШапкеДокумента.Организация;
		Движение.ФизЛицо                		= ВыборкаПоТЧ.ФизЛицо;
			Движение.ПериодВзаиморасчетов           = ВыборкаПоШапкеДокумента.МесяцНалоговогоПериода;
		
		// Ресурсы
		Движение.СуммаВзаиморасчетов			= ВыборкаПоТЧ.СуммаВозвратаПоСтавке13; 
	КонецЕсли;
	
	Если ВыборкаПоТЧ.СуммаВозвратаПоСтавке09 <> 0 Тогда
		Движение = Движения.ВзаиморасчетыСРаботникамиОрганизаций.Добавить();
		// Свойства
		Движение.Период           				= ВыборкаПоШапкеДокумента.Дата;
		Движение.ВидДвижения					= ВидДвиженияНакопления.Приход;
		// Измерения
		Движение.Организация					= ВыборкаПоШапкеДокумента.Организация;
		Движение.ФизЛицо                		= ВыборкаПоТЧ.ФизЛицо;
			Движение.ПериодВзаиморасчетов           = ВыборкаПоШапкеДокумента.МесяцНалоговогоПериода;
		
		// Ресурсы
		Движение.СуммаВзаиморасчетов			= ВыборкаПоТЧ.СуммаВозвратаПоСтавке09; 
	КонецЕсли;
	
	Если ВыборкаПоТЧ.СуммаВозвратаПоСтавке35 <> 0 Тогда
		Движение = Движения.ВзаиморасчетыСРаботникамиОрганизаций.Добавить();
		// Свойства
		Движение.Период           				= ВыборкаПоШапкеДокумента.Дата;
		Движение.ВидДвижения					= ВидДвиженияНакопления.Приход;
		// Измерения
		Движение.Организация					= ВыборкаПоШапкеДокумента.Организация;
		Движение.ФизЛицо                		= ВыборкаПоТЧ.ФизЛицо;
			Движение.ПериодВзаиморасчетов           = ВыборкаПоШапкеДокумента.МесяцНалоговогоПериода;
		
		// Ресурсы
		Движение.СуммаВзаиморасчетов			= ВыборкаПоТЧ.СуммаВозвратаПоСтавке35; 
	КонецЕсли;
	
КонецПроцедуры // ДобавитьСтрокуВДвиженияПоРегистрамНакопления

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ОбработкаПроведения(Отказ, Режим)
	
	// Заголовок для сообщений об ошибках проведения.
	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(Ссылка);
	
	РезультатЗапросаПоШапке = СформироватьЗапросПоШапке(Режим);

	// Получим реквизиты шапки из запроса
	ВыборкаПоШапкеДокумента = РезультатЗапросаПоШапке.Выбрать();

	Если ВыборкаПоШапкеДокумента.Следующий() Тогда

		//Надо позвать проверку заполнения реквизитов шапки
		ПроверитьЗаполнениеШапки(ВыборкаПоШапкеДокумента, Отказ, Заголовок);

		// Движения стоит добавлять, если в проведении еще не отказано (отказ = ложь)
		Если НЕ Отказ Тогда

			// получим реквизиты табличной части
			ВыборкаПоРаботникиОрганизации = СформироватьЗапросПоРаботникиОрганизации(Режим).Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);

			Пока ВыборкаПоРаботникиОрганизации.Следующий() Цикл 

				// проверим очередную строку табличной части
				ПроверитьЗаполнениеСтрокиРаботникиОрганизации(ВыборкаПоРаботникиОрганизации, Отказ, Заголовок);
				
				// Заполним записи в наборах записей регистров
				ДобавитьСтрокуВДвиженияПоРегистрамНакопления(ВыборкаПоШапкеДокумента, ВыборкаПоРаботникиОрганизации);

			КонецЦикла;
		КонецЕсли;

	КонецЕсли;

КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	КраткийСоставДокумента = ПроцедурыУправленияПерсоналом.ЗаполнитьКраткийСоставДокумента(РаботникиОрганизации,, "Физлицо");
	
	Если Не ОбменДанными.Загрузка Тогда
		Если РежимЗаписи = РежимЗаписиДокумента.Проведение  Тогда
			
			ЭтоНеЮрЛицо = Не Организация.ЮрФизЛицо <> Перечисления.ЮрФизЛицо.ФизЛицо;
			
			Для каждого СтрокаТЧ Из РаботникиОрганизации Цикл
				Если ЭтоНеЮрЛицо Тогда
					СтрокаТЧ.КодПоОКАТО = "";
					СтрокаТЧ.КПП = "";
				КонецЕсли;
			КонецЦикла;
			
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры


﻿Перем СохраненнаяНастройка Экспорт;
Перем Расшифровки Экспорт;

#Если Клиент Тогда

Процедура СформироватьОтчет(Результат = Неопределено, ДанныеРасшифровки = Неопределено, ВыводВФормуОтчета = Истина, ВнешниеНаборыДанных = Неопределено) Экспорт
	
	// Проверим заполнение обязательных реквизитов
	Если НалоговыйУчет.ПроверитьЗаполнениеОбязательныхРеквизитов(НачалоПериода,КонецПериода,Организация) Тогда
		Возврат;
	КонецЕсли;
	
	Результат.Очистить();
	
	Настройки = КомпоновщикНастроек.ПолучитьНастройки();
	ВыводЗаголовкаОтчета(ЭтотОбъект, Результат);
	ДоработатьКомпоновщикПередВыводом(ВнешниеНаборыДанных);
	КомпоновщикНастроек.Восстановить();
	НастройкаКомпоновкиДанных = КомпоновщикНастроек.ПолучитьНастройки();
	КомпоновщикНастроек.ЗагрузитьНастройки(Настройки);
	СтандартныеОтчеты.ВывестиОтчет(ЭтотОбъект, Результат, ДанныеРасшифровки, ВыводВФормуОтчета, ВнешниеНаборыДанных, Ложь, НастройкаКомпоновкиДанных);
	
	// Выполним дополнительную обработку Результата отчета
	ОбработкаРезультатаОтчета(Результат);
	
	ВыводПодвалаОтчета(ЭтотОбъект, Результат);
	
	Если Результат.КоличествоУровнейГруппировокСтрок() > 2 Тогда
		Результат.ПоказатьУровеньГруппировокСтрок(Результат.КоличествоУровнейГруппировокСтрок() - 2);
	КонецЕсли;
	
	Возврат;
	
КонецПроцедуры

// В процедуре можно доработать компоновщик перед выводом в отчет
// Изменения сохранены не будут
Процедура ДоработатьКомпоновщикПередВыводом(ВнешниеНаборыДанных) Экспорт
	
	ТиповыеОтчеты.УстановитьПараметр(КомпоновщикНастроек, "НачалоПериода", НачалоПериода);
	ТиповыеОтчеты.УстановитьПараметр(КомпоновщикНастроек, "КонецПериода", КонецДня(КонецПериода));
	
	Если ЗначениеЗаполнено(Организация) Тогда
		ТиповыеОтчеты.ДобавитьОтбор(КомпоновщикНастроек, "Организация", Организация);
	КонецЕсли;
	
КонецПроцедуры

Процедура ВыводЗаголовкаОтчета(ОтчетОбъект, Результат)
	
	МакетЗаголовок = ПолучитьМакет("Отчет");
	ОбластьЗаголовок = МакетЗаголовок.ПолучитьОбласть("Заголовок");
	
	ОбластьЗаголовок.Параметры.ЗаголовокОтчета     = ЭтотОбъект.Метаданные().Синоним;
	СведенияОбОрганизации = УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(Организация);
	НазваниеОрганизации = ФормированиеПечатныхФорм.ОписаниеОрганизации(СведенияОбОрганизации, "НаименованиеДляПечатныхФорм");
	ОбластьЗаголовок.Параметры.НазваниеОрганизации = НазваниеОрганизации;
	ОбластьЗаголовок.Параметры.ИННОрганизации      = СокрЛП(Организация.ИНН) + "/" + СокрЛП(Организация.КПП);
	ОбластьЗаголовок.Параметры.НачалоПериода       = Формат(НачалоПериода, "ДФ=dd.MM.yyyy");
	ОбластьЗаголовок.Параметры.КонецПериода        = Формат(КонецПериода, "ДФ=dd.MM.yyyy");
	
	Результат.Вывести(ОбластьЗаголовок);
			
КонецПроцедуры

Процедура ВыводПодвалаОтчета(ОтчетОбъект, Результат)
	
	МакетЗаголовок = ПолучитьМакет("Отчет");
	ОбластьПодвал = МакетЗаголовок.ПолучитьОбласть("Подвал");
	
	СтруктураЛиц = РегламентированнаяОтчетность.ОтветственныеЛицаОрганизаций(Организация, КонецПериода);
	ОбластьПодвал.Параметры.ОтветственныйЗаРегистры = ОбщегоНазначения.ФамилияИнициалыФизЛица(СтруктураЛиц.ОтветственныйЗаРегистры);
	
	Результат.Вывести(ОбластьПодвал);
			
КонецПроцедуры

Функция ПолучитьТекстЗаголовка(ОрганизацияВНачале = Истина) Экспорт 
	
	ЗаголовокОтчета = ЭтотОбъект.Метаданные().Синоним;
	
	Возврат СтандартныеОтчеты.ПолучитьТекстЗаголовка(ЭтотОбъект, ЗаголовокОтчета, ОрганизацияВНачале);
	
КонецФункции

Процедура ОбработкаРезультатаОтчета(Результат)
	
	СтандартныеОтчеты.ОбработкаРезультатаОтчета(ЭтотОбъект, Результат);
	
КонецПроцедуры

Процедура УстановитьИнтервал() Экспорт
	
	СтандартныеОтчеты.УстановитьИнтервал(ЭтотОбъект);
	
КонецПроцедуры
	
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
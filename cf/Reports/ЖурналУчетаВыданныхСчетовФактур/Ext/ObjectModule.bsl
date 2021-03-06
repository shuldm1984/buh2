﻿ Перем СоответствиеТиповИПредставлений;
 Перем ТипыДокументов;
 Перем ПараметрыСФ;
 Перем мВалютаРегламентированногоУчета;
 
#Если Клиент Тогда

// Формирование отчета в виде табличного документа.
// Параметры:
//  ТабличныйДокумент - макет отчета.
Процедура СформироватьОтчет(ТабличныйДокумент) Экспорт
	
	МассивПрефиксовДляРИБиОрганизации = ОбщегоНазначения.СформироватьМассивПрефиксовДляРИБИОрганизации(Организация);
	
	ТабличныйДокумент.Очистить();
	ТабличныйДокумент.АвтоМасштаб = Истина;
	Макет = ПолучитьМакет("Макет");

	// Вывод шапки
	Секция = Макет.ПолучитьОбласть("Шапка");
	Секция.Параметры.НачалоПериода = Формат(НачалоПериода, "ДФ=dd.MM.yyyy");
	Секция.Параметры.КонецПериода = Формат(КонецПериода, "ДФ=dd.MM.yyyy");
	СведенияОбОрганизации    = УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(Организация, КонецПериода);
	ПредставлениеОрганизации = ФормированиеПечатныхФорм.ОписаниеОрганизации(СведенияОбОрганизации, "НаименованиеДляПечатныхФорм,");
	Секция.Параметры.НазваниеОрганизации = ПредставлениеОрганизации;
	ТабличныйДокумент.Вывести(Секция);
	
	// Выполнение запроса.
	Результат = ПодготовитьОтчетКВыводуНаПечать();
	
	мВалютаРегламентированногоУчета = Константы.ВалютаРегламентированногоУчета.Получить();
	
	Если Результат.Пустой() Тогда
	
		Секция = Макет.ПолучитьОбласть("Строка");
        ТабличныйДокумент.Вывести(Секция);
		УправлениеОтчетами.УстановитьКолонтитулыПоУмолчанию(
			ТабличныйДокумент, , Строка(глЗначениеПеременной("глТекущийПользователь")));
	    Возврат;
		
	КонецЕсли; 
	
	Секция  = Макет.ПолучитьОбласть("Строка");
	Счетчик = 1;
	
	Если НЕ СформироватьОтчетПоСтандартнойФорме И ГруппироватьПоКонтрагентам Тогда
		
		//Режим построения с группировкой по контрагенту
		СекцияКонтрагента = Макет.ПолучитьОбласть("Контрагент");
		ГруппировкаПоКонтрагенту = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		ТабличныйДокумент.НачатьАвтогруппировкуСтрок();
		
		Пока ГруппировкаПоКонтрагенту.Следующий() Цикл
			СекцияКонтрагента.Параметры.Заполнить(ГруппировкаПоКонтрагенту);
			ТабличныйДокумент.Вывести(СекцияКонтрагента,1);
		
			Документ = ГруппировкаПоКонтрагенту.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			
			Пока Документ.Следующий() Цикл
				Секция.Параметры.Заполнить(Документ);
				
				Если ТипЗнч(Документ.СчетФактура) = Тип("ДокументСсылка.КорректировочныйСчетФактураВыданный") Тогда
					ДокументыОснования = Документ.Выбрать();
					Пока ДокументыОснования.Следующий() Цикл
						Секция.Параметры.НПП = Счетчик;
						Если ВыводСтрокиКорректировочногоСФ(ДокументыОснования, Секция, МассивПрефиксовДляРИБиОрганизации) Тогда
							ТабличныйДокумент.Вывести(Секция, 2);
							Счетчик = Счетчик + 1;
						КонецЕсли;
					КонецЦикла;
				Иначе
					Секция.Параметры.НПП = Счетчик;
					Если ВыводСтроки(Документ, Секция, МассивПрефиксовДляРИБиОрганизации) Тогда
						ТабличныйДокумент.Вывести(Секция, 2);
						Счетчик = Счетчик + 1;
					КонецЕсли;
				КонецЕсли;
				
			КонецЦикла; 
			
		КонецЦикла; 
		
		ТабличныйДокумент.ЗакончитьАвтогруппировкуСтрок();
		
	Иначе
		
		// Простой режим
		Документ = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		
		Пока Документ.Следующий() Цикл
			Секция.Параметры.Заполнить(Документ);
			
			Если ТипЗнч(Документ.СчетФактура) = Тип("ДокументСсылка.КорректировочныйСчетФактураВыданный") Тогда
				ДокументыОснования = Документ.Выбрать();
				Пока ДокументыОснования.Следующий() Цикл
					Секция.Параметры.НПП = Счетчик;
					Если ВыводСтрокиКорректировочногоСФ(ДокументыОснования, Секция, МассивПрефиксовДляРИБиОрганизации) Тогда
						ТабличныйДокумент.Вывести(Секция);
						Счетчик = Счетчик + 1;
					КонецЕсли;
				КонецЦикла;
			Иначе
				Секция.Параметры.НПП = Счетчик;
				Если ВыводСтроки(Документ, Секция, МассивПрефиксовДляРИБиОрганизации) Тогда
					ТабличныйДокумент.Вывести(Секция);
					Счетчик = Счетчик + 1;
				КонецЕсли;
			КонецЕсли;
			
		КонецЦикла; 
	
	КонецЕсли;
	
	ТабличныйДокумент.ПовторятьПриПечатиСтроки = ТабличныйДокумент.Области.ШапкаТаблицы;
	
	УправлениеОтчетами.УстановитьКолонтитулыПоУмолчанию(
		ТабличныйДокумент, , Строка(глЗначениеПеременной("глТекущийПользователь")));
	
КонецПроцедуры 

Функция ВыводСтроки(Документ, Секция, МассивПрефиксовДляРИБиОрганизации)
	
	ДокументыОснования = Документ.Выбрать();
	
	ПредставлениеОснования = "";
	
	ВывестиОрганизацию = Ложь;
	
	Пока ДокументыОснования.Следующий() Цикл
		
		ТипДокументаОснования = ТипЗнч(ДокументыОснования.ДокументОснование);
		
		Если НЕ ОтображатьСобственныеСФ 
			И ДокументыОснования.ЭтоНепередаваемыйСчетФактура Тогда
			// Не выводятся счета-фактуры на СМР для собственного потребления
			Продолжить;
		КонецЕсли;
		
		Если ДокументыОснования.ЭтоНепередаваемыйСчетФактура Тогда
			ВывестиОрганизацию = Истина;
		КонецЕсли;
		
		Если ПустаяСтрока(ПредставлениеОснования) Тогда
			Секция.Параметры.ДокументОснование = ДокументыОснования.ДокументОснование;
		Иначе
			ПредставлениеОснования = ПредставлениеОснования + Символы.ПС;
		КонецЕсли; 
				
		ПредставлениеТипа = ПолучитьПредставлениеПоТипу(ТипДокументаОснования);
				
		Если Не ПредставлениеТипа = Неопределено Тогда
			ПредставлениеОснования = ПредставлениеОснования + ПредставлениеТипа 
				+ " № " + ОбщегоНазначения.ПолучитьНомерНаПечать(ДокументыОснования.ДокументОснование, 
				МассивПрефиксовДляРИБиОрганизации)
				+ " от " + Формат(ДокументыОснования.ДатаДокументаОснования, "ДФ=dd.MM.yyyy") + " г.";
		Иначе	
			ПредставлениеОснования = ПредставлениеОснования + Строка(ДокументыОснования.ДокументОснование);
		КонецЕсли; 
		
	КонецЦикла;
	
	Если ПустаяСтрока(ПредставлениеОснования) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Если Документ.ОпределитьПараметрыСчетаФактуры Тогда
		
		УчетНДС.ПолучитьПараметрыСчетаФактуры(Документ.СчетФактура, мВалютаРегламентированногоУчета, ПараметрыСФ);
		Секция.Параметры.Сумма = ?(ПараметрыСФ.СуммаДокумента = 0, "", 
			Формат(ПараметрыСФ.СуммаДокумента, "ЧЦ=19; ЧДЦ=2") + " " + Строка(ПараметрыСФ.ВалютаДокумента));
		
		Секция.Параметры.Контрагент = ПараметрыСФ.Контрагент;
		Если ЗначениеЗаполнено(ПараметрыСФ.Контрагент)  Тогда
			Секция.Параметры.КонтрагентНаименование = ?(ПустаяСтрока(ПараметрыСФ.Контрагент.НаименованиеПолное), 
				СокрЛП(ПараметрыСФ.Контрагент), СокрЛП(ПараметрыСФ.Контрагент.НаименованиеПолное));
		КонецЕсли; 
				
	Иначе
		
		Секция.Параметры.Сумма = ?(Документ.СуммаДокумента = 0, 
			"", Формат(Документ.СуммаДокумента, "ЧЦ=19; ЧДЦ=2") + " " + Строка(Документ.ВалютаДокумента));
				
	КонецЕсли; 
	
	Если ВывестиОрганизацию Тогда
		Секция.Параметры.Контрагент = Документ.Организация;
		Секция.Параметры.КонтрагентНаименование = ?(ПустаяСтрока(Документ.ОрганизацияНаименование), 
			СокрЛП(Документ.Организация), СокрЛП(Документ.ОрганизацияНаименование));
	КонецЕсли; 
		
	Секция.Параметры.ПредставлениеОснования = ПредставлениеОснования;
	
	Секция.Параметры.ДатаНомер = Формат(Документ.Дата, "ДФ=dd.MM.yyyy") 
		+ ", № " + ОбщегоНазначения.ПолучитьНомерНаПечать(Документ, МассивПрефиксовДляРИБиОрганизации);
	
	Возврат Истина;
	
КонецФункции

Функция ВыводСтрокиКорректировочногоСФ(Документ, Секция, МассивПрефиксовДляРИБиОрганизации)
	
	НомерСФ = ОбщегоНазначения.ПолучитьНомерНаПечать(Документ.ДокументОснование, МассивПрефиксовДляРИБиОрганизации);
	ДатаСФ  = Формат(Документ.ДатаДокументаОснования, "ДФ=dd.MM.yyyy");
	
	ТипДокументаОснования = ТипЗнч(Документ.ДокументОснование);
	ПредставлениеТипа     = ПолучитьПредставлениеПоТипу(ТипДокументаОснования);
	
	Если ПредставлениеТипа <> Неопределено Тогда
		ПредставлениеОснования = ПредставлениеТипа + " № " + НомерСФ + " от " + ДатаСФ + " г.";
	Иначе	
		ПредставлениеОснования = Строка(Документ.ДокументОснование);
	КонецЕсли; 
	
	Секция.Параметры.ПредставлениеОснования = ПредставлениеОснования;
	
	Секция.Параметры.ДокументОснование = Документ.ДокументОснование;
	
	Секция.Параметры.Сумма = ?(Документ.СуммаДокумента = 0, 
		"", Формат(Документ.СуммаДокумента, "ЧЦ=19; ЧДЦ=2") + " " + Строка(Документ.ВалютаДокумента));
	
	Секция.Параметры.ДатаНомер = Формат(Документ.Дата, "ДФ=dd.MM.yyyy") 
		+ ", № " + ОбщегоНазначения.ПолучитьНомерНаПечать(Документ, МассивПрефиксовДляРИБиОрганизации);
	
	Возврат Истина;
	
КонецФункции

Функция ПолучитьПредставлениеПоТипу(ТипЗначения)

	Представление =  СоответствиеТиповИПредставлений[ТипЗначения];
	Если Представление = Неопределено Тогда
		Если ТипЗначения <> ТипЗнч(Неопределено) И Документы.ТипВсеСсылки().СодержитТип(ТипЗначения) Тогда
			Представление = Метаданные.НайтиПоТипу(ТипЗначения).Представление();
		Иначе
			Представление = "";	
		КонецЕсли; 
		
		СоответствиеТиповИПредставлений.Вставить(ТипЗначения, Представление);
	КонецЕсли; 
	
	Возврат Представление; 

КонецФункции 

// Функция вызывается из тела процедуры "Сформировать".
// Функция осуществляет первичную обработку результатов запроса к движениям регистра НДСПродажи,
// и по данным запроса заполняет таблицу значений, на основании которой, будет напечатана книга продаж
// Параметры:
// 	Результат - ссылка на результаты выполнения запроса к данным регистра "НДСПродажи"
//  МоментОпределенияНалоговойБазыНДС
Функция ПодготовитьОтчетКВыводуНаПечать()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	РеестрСчетовФактур.Организация КАК Организация,
	|	РеестрСчетовФактур.СчетФактура КАК СчетФактура,
	|	РеестрСчетовФактур.Дата КАК Дата,
	|	РеестрСчетовФактур.Номер КАК Номер,
	|	РеестрСчетовФактур.Контрагент КАК Контрагент,
	|	РеестрСчетовФактур.СуммаДокумента КАК СуммаДокумента,
	|	РеестрСчетовФактур.ВалютаДокумента КАК ВалютаДокумента,
	|	РеестрСчетовФактур.ДокументОснование,
	|	РеестрСчетовФактур.ДатаДокументаОснования,
	|	РеестрСчетовФактур.НомерДокументаОснования,
	|	ВЫБОР
	|		КОГДА РеестрСчетовФактур.ДокументОснование ССЫЛКА Документ.НачислениеНДСпоСМРхозспособом
	|				ИЛИ РеестрСчетовФактур.ДокументОснование ССЫЛКА Документ.ПринятиеКУчетуОС
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК ЭтоНепередаваемыйСчетФактура,
	|	ВЫБОР
	|		КОГДА РеестрСчетовФактур.Контрагент ЕСТЬ NULL 
	|				ИЛИ РеестрСчетовФактур.СуммаДокумента ЕСТЬ NULL 
	|				ИЛИ РеестрСчетовФактур.ВалютаДокумента ЕСТЬ NULL 
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК ОпределитьПараметрыСчетаФактуры,
	|	ВЫБОР
	|		КОГДА ПОДСТРОКА(РеестрСчетовФактур.Контрагент.НаименованиеПолное, 1, 250) = """"
	|			ТОГДА РеестрСчетовФактур.Контрагент.Наименование
	|		ИНАЧЕ ПОДСТРОКА(РеестрСчетовФактур.Контрагент.НаименованиеПолное, 1, 250)
	|	КОНЕЦ КАК КонтрагентНаименование,
	|	ВЫБОР
	|		КОГДА ПОДСТРОКА(РеестрСчетовФактур.Организация.НаименованиеПолное, 1, 250) = """"
	|			ТОГДА РеестрСчетовФактур.Организация.Наименование
	|		ИНАЧЕ ПОДСТРОКА(РеестрСчетовФактур.Организация.НаименованиеПолное, 1, 250)
	|	КОНЕЦ КАК ОрганизацияНаименование
	|ИЗ
	|	(ВЫБРАТЬ
	|		СчетФактураВыданный.Ссылка КАК СчетФактура,
	|		СчетФактураВыданный.Ссылка.Дата КАК Дата,
	|		СчетФактураВыданный.Ссылка.Номер КАК Номер,
	|		СчетФактураВыданный.Ссылка.Организация КАК Организация,
	|		СчетФактураВыданный.Ссылка.Контрагент КАК Контрагент,
	|		СчетФактураВыданный.Ссылка.СуммаДокумента КАК СуммаДокумента,
	|		СчетФактураВыданный.Ссылка.ВалютаДокумента КАК ВалютаДокумента,
	|		СчетФактураВыданный.ДокументОснование КАК ДокументОснование,
	|		СчетФактураВыданный.ДокументОснование.Дата КАК ДатаДокументаОснования,
	|		СчетФактураВыданный.ДокументОснование.Номер КАК НомерДокументаОснования
	|	ИЗ
	|		Документ.СчетФактураВыданный.ДокументыОснования КАК СчетФактураВыданный
	|	ГДЕ
	|		(НЕ СчетФактураВыданный.Ссылка.ПометкаУдаления)
	|		И СчетФактураВыданный.Ссылка.Организация = &Организация
	|		И (&ОтображатьСобственныеСФ
	|				ИЛИ СчетФактураВыданный.Ссылка.ВидСчетаФактуры = ЗНАЧЕНИЕ(Перечисление.НДСВидСчетаФактуры.НаРеализацию)
	|				ИЛИ СчетФактураВыданный.Ссылка.ВидСчетаФактуры = ЗНАЧЕНИЕ(Перечисление.НДСВидСчетаФактуры.НаАванс))
	|		И СчетФактураВыданный.Ссылка.Дата >= &НачалоПериода
	|		И СчетФактураВыданный.Ссылка.Дата <= &КонецПериода
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		КорректировочныйСчетФактура.Ссылка,
	|		КорректировочныйСчетФактура.Дата,
	|		КорректировочныйСчетФактура.Номер,
	|		КорректировочныйСчетФактура.Организация,
	|		КорректировочныйСчетФактура.Контрагент,
	|		-КорректировочныйСчетФактура.РазницаСНДСКУменьшению,
	|		КорректировочныйСчетФактура.ВалютаДокумента,
	|		КорректировочныйСчетФактура.СчетФактура,
	|		КорректировочныйСчетФактура.СчетФактура.Дата,
	|		КорректировочныйСчетФактура.СчетФактура.Номер
	|	ИЗ
	|		Документ.КорректировочныйСчетФактураВыданный КАК КорректировочныйСчетФактура
	|	ГДЕ
	|		(НЕ КорректировочныйСчетФактура.ПометкаУдаления)
	|		И КорректировочныйСчетФактура.Организация = &Организация
	|		И КорректировочныйСчетФактура.Дата >= &НачалоПериода
	|		И КорректировочныйСчетФактура.Дата <= &КонецПериода
	|		И КорректировочныйСчетФактура.РазницаСНДСКУменьшению > 0
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ
	|		КорректировочныйСчетФактура.Ссылка,
	|		КорректировочныйСчетФактура.Дата,
	|		КорректировочныйСчетФактура.Номер,
	|		КорректировочныйСчетФактура.Организация,
	|		КорректировочныйСчетФактура.Контрагент,
	|		КорректировочныйСчетФактура.РазницаСНДСКДоплате,
	|		КорректировочныйСчетФактура.ВалютаДокумента,
	|		КорректировочныйСчетФактура.СчетФактура,
	|		КорректировочныйСчетФактура.СчетФактура.Дата,
	|		КорректировочныйСчетФактура.СчетФактура.Номер
	|	ИЗ
	|		Документ.КорректировочныйСчетФактураВыданный КАК КорректировочныйСчетФактура
	|	ГДЕ
	|		(НЕ КорректировочныйСчетФактура.ПометкаУдаления)
	|		И КорректировочныйСчетФактура.Организация = &Организация
	|		И КорректировочныйСчетФактура.Дата >= &НачалоПериода
	|		И КорректировочныйСчетФактура.Дата <= &КонецПериода
	|		И (КорректировочныйСчетФактура.РазницаСНДСКДоплате > 0
	|				ИЛИ КорректировочныйСчетФактура.РазницаСНДСКДоплате = 0
	|					И КорректировочныйСчетФактура.РазницаСНДСКУменьшению = 0)) КАК РеестрСчетовФактур
	|ГДЕ
	|	ВЫБОР
	|			КОГДА &ОтбиратьПоКонтрагенту
	|				ТОГДА РеестрСчетовФактур.Контрагент В ИЕРАРХИИ (&Контрагент)
	|			ИНАЧЕ ИСТИНА
	|		КОНЕЦ
	|
	|УПОРЯДОЧИТЬ ПО
	|	Дата,
	|	Номер
	|ИТОГИ
	|	МАКСИМУМ(Организация),
	|	МАКСИМУМ(Дата),
	|	МАКСИМУМ(Номер),
	|	МАКСИМУМ(Контрагент),
	|	СУММА(СуммаДокумента),
	|	МАКСИМУМ(ВалютаДокумента),
	|	МАКСИМУМ(ЭтоНепередаваемыйСчетФактура),
	|	МАКСИМУМ(ОпределитьПараметрыСчетаФактуры),
	|	МАКСИМУМ(КонтрагентНаименование),
	|	МАКСИМУМ(ОрганизацияНаименование)
	|ПО
	|	СчетФактура";
	
	Если не СформироватьОтчетПоСтандартнойФорме и ГруппироватьПоКонтрагентам Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, 
		"МАКСИМУМ(ОрганизацияНаименование)
		|ПО
		|	СчетФактура", 
		"МАКСИМУМ(ОрганизацияНаименование)
		|ПО
		|	Контрагент, СчетФактура");
		
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "УПОРЯДОЧИТЬ ПО", "УПОРЯДОЧИТЬ ПО
		|	КонтрагентНаименование, ");
	КонецЕсли; 	
	
	Запрос.УстановитьПараметр("НачалоПериода", НачалоПериода);
	Запрос.УстановитьПараметр("КонецПериода",  КонецДня(КонецПериода));
	Запрос.УстановитьПараметр("Организация",   Организация);
	Запрос.УстановитьПараметр("ОтображатьСобственныеСФ", НЕ СформироватьОтчетПоСтандартнойФорме 
		И ОтображатьСобственныеСФ);
	Запрос.УстановитьПараметр("ОтбиратьПоКонтрагенту", НЕ СформироватьОтчетПоСтандартнойФорме 
		И ОтбиратьПоКонтрагенту 
		И Не КонтрагентДляОтбора = Справочники.Контрагенты.ПустаяСсылка());
	Запрос.УстановитьПараметр("Контрагент", КонтрагентДляОтбора);
	Запрос.УстановитьПараметр("ВалютаРегламентированногоУчета", Константы.ВалютаРегламентированногоУчета.Получить());

	Возврат Запрос.Выполнить();

КонецФункции

#КонецЕсли

СоответствиеТиповИПредставлений = Новый Соответствие();
ТипыДокументов = Документы.ТипВсеСсылки();
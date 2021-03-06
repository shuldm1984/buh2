﻿Перем СтруктураШапкиДокумента;

////////////////////////////////////////////////////////////////////////////////
// ВСПОМОГАТЕЛЬНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ


////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

// Выполняет движения по регистрам 
//
Процедура ДвиженияПоРегистрам(СтруктураШапкиДокумента, Отказ, Заголовок)

	Проводки = Движения.Хозрасчетный;

	// Создание движений документа по БУ
	Для Каждого СтрокаТЧ Из ДанныеБух Цикл

		СформироватьПроводкуБух(Проводки, СтрокаТЧ, СтруктураШапкиДокумента);
		
	КонецЦикла;

КонецПроцедуры

Процедура СформироватьПроводкуБух(Операция, СтрокаТЧ, СтруктураШапкиДокумента)
	
	ОтразитьПоДебету = (СтрокаТЧ.Сумма <> 0);
	СуммаПроводки = ?(ОтразитьПоДебету, СтрокаТЧ.Сумма, СтрокаТЧ.СуммаКт);
	
	Проводка = Операция.Добавить();
	Проводка.Период      = СтруктураШапкиДокумента.Дата;
	Проводка.Организация = СтруктураШапкиДокумента.Организация;
	Проводка.Содержание  = СтрокаТЧ.СодержаниеПроводки;
	Проводка.Сумма = СуммаПроводки;
	
	Если ОтразитьПоДебету Тогда
	
		Проводка.СчетДт = СтрокаТЧ.СчетУчета;
		Для й = 1 По 3 Цикл
			БухгалтерскийУчет.УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, й, СтрокаТЧ["Субконто" + й]);
		КонецЦикла;
		
		БухгалтерскийУчет.УстановитьПодразделениеПроводки(Проводка, СтрокаТЧ.Подразделение, "Дт");
	
		Если СтрокаТЧ.СчетУчета.Валютный Тогда
			Проводка.ВалютаДт = СтрокаТЧ.Валюта;
			Проводка.ВалютнаяСуммаДт = СтрокаТЧ.ВалютнаяСумма;
		КонецЕсли;
		Если СтрокаТЧ.СчетУчета.Количественный Тогда
			Проводка.КоличествоДт = СтрокаТЧ.Количество;
		КонецЕсли;
		
		Если НЕ СтрокаТЧ.СчетУчета.Забалансовый Тогда
			Проводка.СчетКт = СчетРасчетов;
			БухгалтерскийУчет.УстановитьСубконто(Проводка.СчетКт, Проводка.СубконтоКт, 1, ОрганизацияОтправитель);
		КонецЕсли;
		
	Иначе
	
		Если НЕ СтрокаТЧ.СчетУчета.Забалансовый Тогда
			Проводка.СчетДт = СчетРасчетов;
			БухгалтерскийУчет.УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, 1, ОрганизацияОтправитель);
		КонецЕсли;
	
		Проводка.СчетКт = СтрокаТЧ.СчетУчета;
		Для й = 1 По 3 Цикл
			БухгалтерскийУчет.УстановитьСубконто(Проводка.СчетКт, Проводка.СубконтоКт, й, СтрокаТЧ["Субконто" + й]);
		КонецЦикла;
	
		БухгалтерскийУчет.УстановитьПодразделениеПроводки(Проводка, СтрокаТЧ.Подразделение, "Кт");
		
		Если СтрокаТЧ.СчетУчета.Валютный Тогда
			Проводка.ВалютаКт = СтрокаТЧ.Валюта;
			Проводка.ВалютнаяСуммаКт = СтрокаТЧ.ВалютнаяСумма;
		КонецЕсли;
		Если СтрокаТЧ.СчетУчета.Количественный Тогда
			Проводка.КоличествоКт = СтрокаТЧ.Количество;
		КонецЕсли;
		
	КонецЕсли;
		
	Если СтруктураШапкиДокумента.ОтражатьВНалоговомУчете Тогда

		НалоговыйУчет.ЗаполнитьНалоговыеСуммыПроводки(СтрокаТЧ.СуммаНУ,СтрокаТЧ.СуммаНУ,СтрокаТЧ.СуммаПР,СтрокаТЧ.СуммаПР,СтрокаТЧ.СуммаВР,СтрокаТЧ.СуммаВР,Проводка, СтруктураШапкиДокумента.ПрименениеПБУ18);
		
	КонецЕсли;
		
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ОбработкаУдаленияПроведения(Отказ)
	
	ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ, ложь, ложь);
                     
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	Заголовок = ОбщегоНазначения.ПредставлениеДокументаПриПроведении(Ссылка);

	Если ОбщегоНазначения.РучнаяКорректировкаОбработкаПроведения(Ложь, Отказ, Заголовок, ЭтотОбъект) Тогда
		Возврат;
	КонецЕсли;

	// Сформируем структуру реквизитов шапки документа
	СтруктураШапкиДокумента = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);
	
	ПроверитьЗаполнениеДокумента(СтруктураШапкиДокумента,Отказ, Заголовок);

	Если НЕ Отказ Тогда
		
		ДвиженияПоРегистрам(СтруктураШапкиДокумента, Отказ, Заголовок);
		
	КонецЕсли;

КонецПроцедуры

Процедура ОбработкаЗаполнения(Основание)
	
	Если ТипЗнч(Основание) = Тип("ДокументСсылка.АвизоПрочееИсходящее") Тогда
		
		СкопироватьДанныеБух(Основание);
		
	КонецЕсли;
	
КонецПроцедуры

Процедура СкопироватьДанныеБух(Основание) Экспорт

	ПараметрыДокументаОснования = ОбщегоНазначения.СформироватьСтруктуруШапкиДокумента(Основание);
	ДокументОснование           = ПараметрыДокументаОснования.Ссылка;
	
	СчетРасчетов = ПараметрыДокументаОснования.СчетРасчетов;
	Организация = ПараметрыДокументаОснования.ОрганизацияПолучатель;
	ОрганизацияОтправитель = ПараметрыДокументаОснования.Организация;
	НомерВходящегоДокумента = ОбщегоНазначения.ПолучитьНомерНаПечать(ПараметрыДокументаОснования);
	ДатаВходящегоДокумента = ПараметрыДокументаОснования.Дата;
	Ответственный = глЗначениеПеременной("глТекущийПользователь");

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", ДокументОснование);
	Запрос.Текст = "ВЫБРАТЬ
	               |		СчетУчета,
	               |		Субконто1,
	               |		Субконто2,
	               |		Субконто3,
	               |		Сумма как СуммаКТ,
	               |		СуммаНУ,
	               |		СуммаПР,
	               |		СуммаВР,
	               |		СуммаКТ как Сумма,
	               |		Количество,
	               |		Валюта,
	               |		ВалютнаяСумма,
	               |		СодержаниеПроводки
	               |ИЗ
	               |	Документ.АвизоПрочееИсходящее.ДанныеБух КАК АвизоИсходящее
	               |
	               |ГДЕ
	               |	АвизоИсходящее.Ссылка = &Ссылка";
	ДанныеБух.Загрузить(Запрос.Выполнить().Выгрузить());
	
КонецПроцедуры

Процедура ПроверитьЗаполнениеДокумента(СтруктураШапкиДокумента, Отказ, Заголовок)
	
	СтруктураПолей = Новый Структура("Организация");
	
	СтруктураПолей.Вставить("СчетРасчетов",       "Не указан счет расчетов прочих операций");
	СтруктураПолей.Вставить("ОрганизацияОтправитель","Не указана организация отправитель!");
	СтруктураПолей.Вставить("НомерВходящегоДокумента","Не указан номер входящего документа!");
	СтруктураПолей.Вставить("ДатаВходящегоДокумента","Не указана дата входящего документа!");
	СтруктураПолей.Вставить("ДокументОснование","Не выбран документ-основание!");
		                                                        
	ЗаполнениеДокументов.ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект,СтруктураПолей, Отказ, Заголовок);
	
КонецПроцедуры


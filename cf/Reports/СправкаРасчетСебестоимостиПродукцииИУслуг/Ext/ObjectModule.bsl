﻿#Если Клиент Тогда
	
	Перем НП Экспорт;
	
	Функция СформироватьТекстЗапроса()
		
		Текст	= "ВЫБРАТЬ
		     	  |	РасчетСебестоимостиПродукции.ПериодРасчета КАК ПериодРасчета,
		     	  |	РасчетСебестоимостиПродукции.СчетУчета КАК СчетУчета,
		     	  |	РасчетСебестоимостиПродукции.Подразделение КАК Подразделение,
		     	  |	РасчетСебестоимостиПродукции.НоменклатурнаяГруппа КАК НоменклатурнаяГруппа,
		     	  |	РасчетСебестоимостиПродукции.Продукция КАК Продукция,
		     	  |	РасчетСебестоимостиПродукции.СуммаПлан КАК СуммаПлан,
		     	  |	РасчетСебестоимостиПродукции.Сумма КАК Сумма,
		     	  |	РасчетСебестоимостиПродукции.СуммаПР КАК СуммаПР,
		     	  |	РасчетСебестоимостиПродукции.СуммаВР КАК СуммаВР,
		     	  |	РасчетСебестоимостиПродукции.СуммаНЗП КАК СуммаНЗП,
		     	  |	РасчетСебестоимостиПродукции.СуммаНЗППР КАК СуммаНЗППР,
		     	  |	РасчетСебестоимостиПродукции.СуммаНЗПВР КАК СуммаНЗПВР
		     	  |ИЗ
		     	  |	РегистрСведений.РасчетСебестоимостиПродукции КАК РасчетСебестоимостиПродукции
		     	  |ГДЕ
		     	  |	РасчетСебестоимостиПродукции.Активность
		     	  |	И (НЕ РасчетСебестоимостиПродукции.ВидОперации = &УслугиБезПлановыхЦен)
		     	  |	И РасчетСебестоимостиПродукции.Организация = &Организация
		     	  |	И РасчетСебестоимостиПродукции.ПериодРасчета МЕЖДУ &ДатаНач И &ДатаКон
		     	  |
		     	  |УПОРЯДОЧИТЬ ПО
		     	  |	Подразделение,
		     	  |	НоменклатурнаяГруппа,
		     	  |	Продукция
		     	  |ИТОГИ
		     	  |	МАКСИМУМ(СуммаПлан),
		     	  |	СУММА(Сумма),
		     	  |	СУММА(СуммаПР),
		     	  |	СУММА(СуммаВР),
		     	  |	СУММА(СуммаНЗП),
		     	  |	СУММА(СуммаНЗППР),
		     	  |	СУММА(СуммаНЗПВР)
		     	  |ПО
		     	  |	ПериодРасчета,
		     	  |	СчетУчета,
		     	  |	Подразделение,
		     	  |	НоменклатурнаяГруппа,
		     	  |	Продукция";	
				  
		Возврат Текст;
		
	КонецФункции
	
	// Выполняет запрос и формирует табличный документ-результат отчета
	// в соответствии с настройками, заданными значениями реквизитов отчета.
	//
	// Параметры:
	//	ДокументРезультат - табличный документ, формируемый отчетом
	//	ПоказыватьЗаголовок - признак видимости строк с заголовком отчета
	//	ВысотаЗаголовка - параметр, через который возвращается высота заголовка в строках 
	//
	
	Процедура СформироватьОтчет(ДокументРезультат, ПоказыватьЗаголовок, ВысотаЗаголовка, ТолькоЗаголовок = Ложь, НачалоПодписи, ПоказыватьПодписи) Экспорт
		
		ДатаНач = НачалоМесяца(ПериодРегистрации);
		ДатаКон  = КонецМесяца(ПериодРегистрации);
		Если ДатаНач > ДатаКон И ДатаКон <> '00010101000000' Тогда
			Предупреждение("Дата начала периода не может быть больше даты окончания периода");
			Возврат;
		КонецЕсли;
		НачалоПериода = НачалоДня(ДатаНач);
		КонецПериода  = КонецДня(ДатаКон);
		
		ДокументРезультат.Очистить();
		
		Макет      = ПолучитьМакет("Отчет");
		МакетОбщий = ПолучитьОбщийМакет("СправкаРасчет");
		
		ЗаголовокОтчета = МакетОбщий.ПолучитьОбласть("Заголовок");
		
		
		// Когда нужен только заголовок:
		Если ТолькоЗаголовок Тогда
			Возврат;
		КонецЕсли;
		
		Если ЗначениеЗаполнено(ВысотаЗаголовка) Тогда
			ДокументРезультат.Область("R1:R" + ВысотаЗаголовка).Видимость = ПоказыватьЗаголовок;
		КонецЕсли;
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("ДатаНач",     НачалоДня(ДатаНач));
		Запрос.УстановитьПараметр("ДатаКон",     КонецДня(ДатаКон));
		Запрос.УстановитьПараметр("Организация", Организация);
		Запрос.УстановитьПараметр("УслугиБезПлановыхЦен",  Перечисления.ВидыОперацийРасчетаСебестоимости.УслугиБезИспользованияПлановыхЦен);
		ОграниченияПоПостроителюОтчета = СтандартныеОтчеты.ПолучитьТекстОграниченийПоПостроителюОтчета(ПостроительОтчета, Запрос);
		
		Если Не ПустаяСтрока(ОграниченияПоПостроителюОтчета) Тогда
			
			ОграниченияПоПостроителюОтчета = " И " + ОграниченияПоПостроителюОтчета;
			ОграниченияПоПостроителюОтчета = СтрЗаменить(ОграниченияПоПостроителюОтчета, "Субконто1", "Подразделение");
			ОграниченияПоПостроителюОтчета = СтрЗаменить(ОграниченияПоПостроителюОтчета, "Субконто2", "НоменклатурнаяГруппа");
			
		КонецЕсли;
		
		Запрос.Текст = СформироватьТекстЗапроса();
		
		Запрос.Текст  = СтрЗаменить(Запрос.Текст, "Активность","Активность " + ОграниченияПоПостроителюОтчета);
		
		Если ВариантОтчета = 2 Тогда
		Запрос.Текст  = СтрЗаменить(Запрос.Текст, "Сумма КАК Сумма,","СуммаНУ КАК Сумма,");
		Запрос.Текст  = СтрЗаменить(Запрос.Текст, "СуммаНЗП КАК СуммаНЗП,","СуммаНЗПНУ КАК СуммаНЗП,");
		КонецЕсли;	
		
		Если ВариантОперации = 2 Тогда
			Запрос.Текст  = СтрЗаменить(Запрос.Текст, "НЕ РасчетСебестоимостиПродукции.ВидОперации", "РасчетСебестоимостиПродукции.ВидОперации");
		КонецЕсли;
		
		Результат = Запрос.Выполнить();
		
		ОбластьШапка            = Макет.ПолучитьОбласть("Шапка");
		ОбластьШапкаУслуги      = Макет.ПолучитьОбласть("ШапкаУслуги");
		ОбластьСтрока           = Макет.ПолучитьОбласть("Строка");
		ОбластьСтрокаУслуги     = Макет.ПолучитьОбласть("СтрокаУслуги");
		ОбластьПодСтрока        = Макет.ПолучитьОбласть("ПодСтрока");
		ОбластьСтрокаРазницыУслуги = Макет.ПолучитьОбласть("СтрокаРазницыУслуги");
		ОбластьПодСтрокаРазницы = Макет.ПолучитьОбласть("ПодСтрокаРазницы");
		ОбластьСтрокаРазницы    = Макет.ПолучитьОбласть("СтрокаРазницы");
		ОбластьИтого            = Макет.ПолучитьОбласть("Итого");
		ОбластьИтогоРазницы     = Макет.ПолучитьОбласть("ИтогоРазницы");
		ОбластьВсего            = Макет.ПолучитьОбласть("Всего");
		ОбластьВсегоУслуги      = Макет.ПолучитьОбласть("ВсегоУслуги");
		ОбластьВсегоУслугиПоСчету  = Макет.ПолучитьОбласть("ВсегоУслугиПоСчету");
		ОбластьРазницыВсего     = Макет.ПолучитьОбласть("ВсегоРазницы");
		ОбластьРазницыВсегоУслуги= Макет.ПолучитьОбласть("ВсегоРазницыУслуги");
		ОбластьОкончаниеТаблицы = Макет.ПолучитьОбласть("ОкончаниеТаблицы");
		ОбластьОкончаниеТаблицыУслуги = Макет.ПолучитьОбласть("ОкончаниеТаблицыУслуги");
		ОбластьПодвал           = МакетОбщий.ПолучитьОбласть("Подвал");
		
		ВыборкаПериод = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Всего = 0;
		ВсегоПериодБаза = 0;
		Пока ВыборкаПериод.Следующий() Цикл
			
			ЗаголовокОтчета.Параметры.Период              = "" + ПредставлениеПериода(НачалоМесяца(ВыборкаПериод.ПериодРасчета), КонецМесяца(ВыборкаПериод.ПериодРасчета), "ФП = Истина");
			СведенияОбОрганизации = УправлениеКонтактнойИнформацией.СведенияОЮрФизЛице(Организация);
			НазваниеОрганизации = ФормированиеПечатныхФорм.ОписаниеОрганизации(СведенияОбОрганизации, "НаименованиеДляПечатныхФорм");
			ЗаголовокОтчета.Параметры.НазваниеОрганизации = НазваниеОрганизации;
			ЗаголовокОтчета.Параметры.ДатаСоставления     = КонецМесяца(ВыборкаПериод.ПериодРасчета);
			ЗаголовокОтчета.Параметры.НазваниеОтчета      = ?(ВариантОтчета = 2, "Прямые расходы, приходящиеся на стоимость ", "Себестоимость ") + ?(ВариантОперации = 1, "выпущенной продукции и ", "") + "оказанных услуг производственного характера (" +?(ВариантОтчета = 2, "налоговый учет", "бухгалтерский учет") + ")";
			ДокументРезультат.Вывести(ЗаголовокОтчета);
			
			СтрОтбор = УправлениеОтчетами.СформироватьСтрокуОтборов(ПостроительОтчета.Отбор);
			Если Не ПустаяСтрока(СтрОтбор) Тогда
				ОбластьОтбор = МакетОбщий.ПолучитьОбласть("СтрокаОтбор");
				ОбластьОтбор.Параметры.ТекстПроОтбор = "Отбор: " + СтрОтбор;
				ДокументРезультат.Вывести(ОбластьОтбор);
			КонецЕсли;
			
			// Параметр для показа заголовка
			ВысотаЗаголовка = ДокументРезультат.ВысотаТаблицы;
			
			ОбластьШапка.Параметры.ТекстРасходов       = ?(ВариантОтчета = 2, "Прямые расходы", "Производственные расходы");
			ОбластьШапка.Параметры.ТекстСебестоимости  = ?(ВариантОтчета = 2, "Сумма прямых расходов, приходящаяся на выпуск", "Фактическая себестоимость") + " (гр.6 * гр.9)";
			ДокументРезультат.Вывести(?(ВариантОперации = 2, ОбластьШапкаУслуги, ОбластьШапка));
			
			ВыборкаСчет = ВыборкаПериод.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			Пока ВыборкаСчет.Следующий() Цикл
				ВыборкаПодразделение = ВыборкаСчет.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
				
				Пока ВыборкаПодразделение.Следующий() Цикл
					ВыборкаНомГруппа = ВыборкаПодразделение.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
					Пока ВыборкаНомГруппа.Следующий() Цикл
						ПерваяСтрока = Истина;
						ПоказыватьСтрокуИтого = Истина; 
						Выборка = ВыборкаНомГруппа.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
						ВсегоБаза = 0;
						ВсегоСумма = 0;
						Пока Выборка.Следующий() Цикл
							ВсегоБаза  = ВсегоБаза + Выборка.СуммаПлан;
							ВсегоСумма = ВсегоСумма + Выборка.СуммаПлан + Выборка.Сумма;
						КонецЦикла;
						Если ВариантОперации = 1 Тогда
							Выборка = ВыборкаНомГруппа.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
							
							Пока Выборка.Следующий() Цикл
								
								Если ПерваяСтрока Тогда
									Область = ОбластьСтрока;
									ОбластьРазницы = ОбластьСтрокаРазницы;
									Область.Параметры.СчетЗатрат           = ВыборкаНомГруппа.СчетУчета;
									Область.Параметры.Подразделение        = ВыборкаНомГруппа.Подразделение;
									Область.Параметры.НоменклатурнаяГруппа = ВыборкаНомГруппа.НоменклатурнаяГруппа;
									Область.Параметры.СуммаРасходовБезНЗП  = ВсегоСумма;
									Область.Параметры.СуммаНЗП             = ВыборкаНомГруппа.СуммаНЗП;
									Область.Параметры.СуммаРасходов        = ВсегоСумма + ВыборкаНомГруппа.СуммаНЗП;
									
								Иначе
									Область =  ОбластьПодСтрока;
									ОбластьРазницы = ОбластьПодСтрокаРазницы;
								КонецЕсли;
								
								Область.Параметры.Продукция            = УправлениеПроизводством.ВыводНаименованияВыпуска(Выборка.Продукция, Ложь, Истина);
								Область.Параметры.Коэффициент          = ?(ВсегоБаза = 0, 0, Выборка.СуммаПлан / ВсегоБаза);
								Область.Параметры.СуммаБазы            = Выборка.СуммаПлан;
								Область.Параметры.СуммаОтклонения      = Выборка.Сумма;
								Область.Параметры.Сумма                = Выборка.Сумма + Выборка.СуммаПлан;
								ПоказыватьСтрокуИтого                  = Не (Выборка.СуммаПлан = ВсегоБаза); 
								ВсегоПериодБаза = ВсегоПериодБаза +  Выборка.СуммаПлан;
								ДокументРезультат.Вывести(Область);
								
								Если ВариантОтчета = 3 Тогда
									Если ПерваяСтрока Тогда
										ОбластьРазницы.Параметры.СуммаРасходовБезНЗП  = ПоказатьРазницы("ПР", ВыборкаНомГруппа.СуммаПР);
										ОбластьРазницы.Параметры.СуммаНЗП             = ПоказатьРазницы("ПР", ВыборкаНомГруппа.СуммаНЗППР);
										ОбластьРазницы.Параметры.СуммаРасходов        = ПоказатьРазницы("ПР", ВыборкаНомГруппа.СуммаПР + ВыборкаНомГруппа.СуммаНЗППР);
									КонецЕсли;
									ОбластьРазницы.Параметры.Сумма                = ПоказатьРазницы("ПР", Выборка.СуммаПР);
									
									Если Не Выборка.СуммаПР = 0 ИЛИ Не Выборка.СуммаНЗППР = 0 Тогда
										ДокументРезультат.Вывести(ОбластьРазницы);
									КонецЕсли;
									Если ПерваяСтрока Тогда
										ОбластьРазницы.Параметры.СуммаРасходовБезНЗП  = ПоказатьРазницы("ВР", ВыборкаНомГруппа.СуммаВР);
										ОбластьРазницы.Параметры.СуммаНЗП             = ПоказатьРазницы("ВР", ВыборкаНомГруппа.СуммаНЗПВР);
										ОбластьРазницы.Параметры.СуммаРасходов        = ПоказатьРазницы("ВР", ВыборкаНомГруппа.СуммаВР + ВыборкаНомГруппа.СуммаНЗПВР);
									КонецЕсли;
									ОбластьРазницы.Параметры.Сумма                = ПоказатьРазницы("ВР", Выборка.СуммаВР);
									
									Если Не Выборка.СуммаВР = 0  ИЛИ Не Выборка.СуммаНЗПВР = 0 Тогда
										ДокументРезультат.Вывести(ОбластьРазницы);
									КонецЕсли;
								КонецЕсли;
								ПерваяСтрока = Ложь;
							КонецЦикла;  	
						Иначе
							
							Область = ОбластьСтрокаУслуги;
							Область.Параметры.СчетЗатрат           = ВыборкаНомГруппа.СчетУчета;
							Область.Параметры.Подразделение        = ВыборкаНомГруппа.Подразделение;
							Область.Параметры.НоменклатурнаяГруппа = ВыборкаНомГруппа.НоменклатурнаяГруппа;
							Область.Параметры.СуммаРасходовБезНЗП  = ВыборкаНомГруппа.Сумма + ВыборкаНомГруппа.СуммаПлан;
							Область.Параметры.СуммаНЗП             = ВыборкаНомГруппа.СуммаНЗП;
							Область.Параметры.СуммаРасходов        = ВыборкаНомГруппа.Сумма + ВыборкаНомГруппа.СуммаПлан + ВыборкаНомГруппа.СуммаНЗП;
							ВсегоПериодБаза = ВсегоПериодБаза +  ВыборкаНомГруппа.СуммаПлан;
							ПоказыватьСтрокуИтого                      = Ложь; 
							
							ДокументРезультат.Вывести(Область);
							
							Если ВариантОтчета = 3 Тогда
								Область = ОбластьСтрокаРазницыУслуги;
								Область.Параметры.СуммаРасходовБезНЗП  = ПоказатьРазницы("ПР", ВыборкаНомГруппа.СуммаПР);
								Область.Параметры.СуммаНЗП             = ПоказатьРазницы("ПР", ВыборкаНомГруппа.СуммаНЗППР);
								Область.Параметры.СуммаРасходов        = ПоказатьРазницы("ПР", ВыборкаНомГруппа.СуммаПР + ВыборкаНомГруппа.СуммаНЗППР);
								
								Если Не Выборка.СуммаПР = 0 Тогда
									ДокументРезультат.Вывести(Область);
								КонецЕсли;
								
								Область.Параметры.СуммаРасходовБезНЗП  = ПоказатьРазницы("ВР", ВыборкаНомГруппа.СуммаВР);
								Область.Параметры.СуммаНЗП             = ПоказатьРазницы("ВР", ВыборкаНомГруппа.СуммаНЗПВР);
								Область.Параметры.СуммаРасходов        = ПоказатьРазницы("ВР", ВыборкаНомГруппа.СуммаВР + ВыборкаНомГруппа.СуммаНЗПВР);
								
								Если Не Выборка.СуммаВР = 0 Тогда
									ДокументРезультат.Вывести(Область);
								КонецЕсли;
							КонецЕсли;
							
						КонецЕсли;
						
						
						Если ПоказыватьСтрокуИтого Тогда
							ОбластьИтого.Параметры.Сумма           = ВсегоСумма;
							ОбластьИтого.Параметры.СуммаБазы       = ВсегоБаза;
							ОбластьИтого.Параметры.СуммаОтклонения = ВсегоСумма - ВсегоБаза;
							ДокументРезультат.Вывести(ОбластьИтого);
							
							Если ВариантОтчета = 3 Тогда
								СуммаПР = ВыборкаНомГруппа.СуммаПР;
								СуммаВР = ВыборкаНомГруппа.СуммаВР;
								Если Не СуммаПР = 0 Тогда
									ОбластьИтогоРазницы.Параметры.Сумма = ПоказатьРазницы("ПР", СуммаПР);
									ДокументРезультат.Вывести(ОбластьИтогоРазницы);
								КонецЕсли;
								Если Не СуммаВР = 0 Тогда
									ОбластьИтогоРазницы.Параметры.Сумма = ПоказатьРазницы("ВР", СуммаВР);
									ДокументРезультат.Вывести(ОбластьИтогоРазницы);
								КонецЕсли;
								
							КонецЕсли;
						КонецЕсли;
						
					КонецЦикла;  // НомГруппа
				КонецЦикла;  //  Подразделение
				
				
				Если ВариантОперации = 2 И ВариантОтчета = 2 Тогда
					Область        = ОбластьВсегоУслугиПОСЧету;
					Область.Параметры.СуммаРасходовБезНЗП  = ВыборкаСчет.Сумма + ВыборкаСчет.СуммаПлан;
					Область.Параметры.СуммаНЗП             = ВыборкаСчет.СуммаНЗП;
					Область.Параметры.СуммаРасходов        = ВыборкаСчет.Сумма + ВыборкаСчет.СуммаПлан + ВыборкаСчет.СуммаНЗП;
					Область.Параметры.СтрИтого =  ?(ВыборкаСчет.СчетУчета = ПланыСчетов.Хозрасчетный.СебестоимостьПродажЕНВД, "Итого исключено из НУ:", "Итого:");
	            	ДокументРезультат.Вывести(Область);
				КонецЕсли;
				
			КонецЦикла;  //  СчетУчета
			
			Область        = ?(ВариантОперации = 1, ОбластьВсего, ОбластьВсегоУслуги);
			
			Область.Параметры.СуммаРасходовБезНЗП  = ВыборкаПериод.Сумма + ВсегоПериодБаза;
			Область.Параметры.СуммаНЗП             = ВыборкаПериод.СуммаНЗП;
			Область.Параметры.СуммаРасходов        = ВыборкаПериод.Сумма + ВсегоПериодБаза + ВыборкаПериод.СуммаНЗП;
			
			Если ВариантОперации = 1 Тогда
				Область.Параметры.Сумма                = ВыборкаПериод.Сумма + ВсегоПериодБаза;
			КонецЕсли;
			ДокументРезультат.Вывести(Область);
			Если ВариантОтчета = 3 Тогда
				ОбластьРазницы = ?(ВариантОперации = 1, ОбластьРазницыВсего, ОбластьРазницыВсегоУслуги);
				ОбластьРазницы.Параметры.СуммаРасходовБезНЗП  = ПоказатьРазницы("ПР", ВыборкаПериод.СуммаПР);
				ОбластьРазницы.Параметры.СуммаНЗП             = ПоказатьРазницы("ПР", ВыборкаПериод.СуммаНЗППР);
				ОбластьРазницы.Параметры.СуммаРасходов        = ПоказатьРазницы("ПР", ВыборкаПериод.СуммаПР + ВыборкаПериод.СуммаНЗППР);
				Если ВариантОперации = 1 Тогда
					ОбластьРазницы.Параметры.Сумма                = ПоказатьРазницы("ПР", ВыборкаПериод.СуммаПР);
				КонецЕсли;
				Если НЕ ВыборкаПериод.СуммаПР = 0 Тогда
					ДокументРезультат.Вывести(ОбластьРазницы);
				КонецЕсли;
				
				ОбластьРазницы.Параметры.СуммаРасходовБезНЗП  = ПоказатьРазницы("ВР", ВыборкаПериод.СуммаВР);
				ОбластьРазницы.Параметры.СуммаНЗП             = ПоказатьРазницы("ВР", ВыборкаПериод.СуммаНЗПВР);
				ОбластьРазницы.Параметры.СуммаРасходов        = ПоказатьРазницы("ВР", ВыборкаПериод.СуммаВР + ВыборкаПериод.СуммаНЗПВР);
				Если ВариантОперации = 1 Тогда
					ОбластьРазницы.Параметры.Сумма                = ПоказатьРазницы("ВР", ВыборкаПериод.СуммаВР);
				КонецЕсли;
				Если Не ВыборкаПериод.СуммаВР = 0 Тогда
					ДокументРезультат.Вывести(ОбластьРазницы);
				КонецЕсли;
			КонецЕсли;
			
			ДокументРезультат.Вывести(?(ВариантОперации = 1, ОбластьОкончаниеТаблицы, ОбластьОкончаниеТаблицыУслуги));
			
			
			ОбластьПодвал.Параметры.ТекстПримечания = ?(ВариантОтчета = 3, "ПР: Постоянные разницы в оценке стоимости активов и обязательств. ВР: Временные разницы в оценке стоимости активов и обязательств.", "");
			ДокументРезультат.Вывести(ОбластьПодвал);
			
			ВысотаПодписи = ДокументРезультат.Области.Подвал.Низ - ДокументРезультат.Области.Подвал.Верх;
			
			ДокументРезультат.Области.Подвал.Видимость = ПоказыватьПодписи;
			
		КонецЦикла;    // Период	
		
		
		Если Не Результат.Пустой() Тогда
			// Зафиксируем заголовок отчета
			ДокументРезультат.ФиксацияСверху = 10;
		КонецЕсли;
	
		// Первую колонку не печатаем
		ДокументРезультат.ОбластьПечати = ДокументРезультат.Область(1,2,ДокументРезультат.ВысотаТаблицы,ДокументРезультат.ШиринаТаблицы);
		
		// Присвоим имя для сохранения параметров печати табличного документа
		ДокументРезультат.ИмяПараметровПечати = "Расчет себестоимости продукции";
		
		УправлениеОтчетами.УстановитьКолонтитулыПоУмолчанию(ДокументРезультат, ЗаголовокОтчета, Строка(глЗначениеПеременной("глТекущийПользователь")));
		
	КонецПроцедуры // СформироватьОтчет
	
	Функция ПоказатьРазницы(Разницы, СуммаРазниц)
		
		Если СуммаРазниц = 0 Тогда
			Возврат "";
		Иначе
			Возврат Разницы + ": " + Формат(СуммаРазниц, "ЧДЦ=2");
		КонецЕсли;
		
	КонецФункции
	
	
    Процедура ЗаполнитьНачальныеНастройки() Экспорт
	
	СтарыеНастройки = УправлениеОтчетами.ПолучитьКопиюОтбораВТЗ(ПостроительОтчета.Отбор);
	
	СоотвСубконто = Новый Соответствие;
	
	Текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ
	        |	ХозрасчетныйОбороты.СуммаОборотКт КАК СуммаОборотКт
	        |{ВЫБРАТЬ
	        |	ХозрасчетныйОбороты.Субконто1 КАК Субконто1}
	        |ИЗ
	        |	РегистрБухгалтерии.Хозрасчетный.Обороты(, , Месяц, Счет В ИЕРАРХИИ (&Счет), , {(Субконто1).*}, , ) КАК ХозрасчетныйОбороты
	        |ИТОГИ
	        |	СУММА(СуммаОборотКт)
	        |ПО
	        |	ОБЩИЕ
	        |{ИТОГИ ПО
	        |	ХозрасчетныйОбороты.Субконто1.*}";

Массив = Новый Массив;
Массив.Добавить(ПланыСчетов.Хозрасчетный.ОсновноеПроизводство);
Массив.Добавить(ПланыСчетов.Хозрасчетный.ВспомогательныеПроизводства);

ПостроительОтчета.Параметры.Вставить("Счет", Массив);
ПостроительОтчета.Параметры.Вставить("ПустаяОрганизация", Справочники.Организации.ПустаяСсылка());
	
ПостроительОтчета.Текст = Текст;

СоотвСубконто = Новый Соответствие;
СоотвСубконто.Вставить("Субконто1",    ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.НоменклатурныеГруппы);
		
	Сч = 0;
	Для каждого Элемент Из СоотвСубконто Цикл
		Сч = Сч+1;
		Поле = ПостроительОтчета.ДоступныеПоля.Найти(Элемент.Ключ);
		Поле.ТипЗначения = Элемент.Значение.ТипЗначения;
		Поле.Представление = Элемент.Значение.Наименование;
		
		ПостроительОтчета.Отбор.Добавить(Элемент.Ключ);
	КонецЦикла;

УправлениеОтчетами.УстановитьОтборИзТаблицы(ПостроительОтчета.Отбор, СтарыеНастройки);

КонецПроцедуры
	////////////////////////////////////////////////////////////////////////////////
	// ОПЕРАТОРЫ ОСНОВНОЙ ПРОГРАММЫ
	// 
	
	НП = Новый НастройкаПериода;
	
#КонецЕсли
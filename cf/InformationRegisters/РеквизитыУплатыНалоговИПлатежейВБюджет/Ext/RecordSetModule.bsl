﻿
Процедура ПередЗаписью(Отказ, Замещение)
	
	Заголовок = "Запись реквизитов уплаты налогов и иных платежей в бюджет";
	Для каждого Запись Из ЭтотОбъект Цикл
		Если НЕ ЗначениеЗаполнено(Запись.ВидПлатежа) Тогда
			ОбщегоНазначения.СообщитьОбОшибке("Не заполнен вид платежа", Отказ, Заголовок);
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(Запись.ВидПеречисленияВБюджет) Тогда
			ОбщегоНазначения.СообщитьОбОшибке("Не заполнен вид перечисления", Отказ, Заголовок);
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

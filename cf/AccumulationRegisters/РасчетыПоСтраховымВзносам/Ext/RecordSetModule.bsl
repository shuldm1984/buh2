﻿
Процедура ПередЗаписью(Отказ, Замещение)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Для каждого СтрокаДанных Из ЭтотОбъект Цикл
		СтрокаДанных.МесяцРасчетногоПериода = НачалоМесяца(СтрокаДанных.МесяцРасчетногоПериода);
		Если ЗначениеЗаполнено(СтрокаДанных.МесяцРасчетногоПериода) И СтрокаДанных.МесяцРасчетногоПериода >= ПроведениеРасчетов.ДатаЗаменыЕСНСтраховымиВзносами() Тогда
			СтрокаДанных.ОтчетныйПериодПерсучетаПФР = ПроцедурыПерсонифицированногоУчета.НачалоОтчетногоПериодаПерсучета(СтрокаДанных.МесяцРасчетногоПериода);
		КонецЕсли;
	КонецЦикла; 
	
КонецПроцедуры

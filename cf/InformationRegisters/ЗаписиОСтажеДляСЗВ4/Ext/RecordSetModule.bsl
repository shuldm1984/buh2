﻿
Процедура ПередЗаписью(Отказ, Замещение)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Для каждого СтрокаНабора Из ЭтотОбъект Цикл
		СтрокаНабора.Год = Год(СтрокаНабора.ОтчетныйПериод);
		Если Год(СтрокаНабора.ОтчетныйПериод) < 2010 Тогда
			СтрокаНабора.КатегорияЗастрахованныхЛиц = ""
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры
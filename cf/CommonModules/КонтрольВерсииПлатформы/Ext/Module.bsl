﻿// Данная функция возвращает строку с версией платформы, которая требуется для работы конфигурации. 
// Версия возвращается в формате <основная версия>.<младшая версия>.<релиз>.<дополнительный номер релиза>
// или более коротком, например, "8.1.10.5", "8.1.13"
// Если требований к версии платформы нет, функция может возвращать пустую строку
Функция РекомендуемаяВерсияПлатформы()
	Возврат "8.1.13";
КонецФункции

// Проверка версии платформы.
// Если версия платформы боле поздняя, чем требуется, работа программы будет прекращена.
Процедура ПроверитьВерсиюПлатформы() Экспорт
	
	СистемнаяИнформация = Новый СистемнаяИнформация;
	ТекущаяВерсия = ОбщегоНазначения.РазложитьСтрокуВМассивПодстрок(СистемнаяИнформация.ВерсияПриложения, ".");
	РекомендуемаяВерсия = ОбщегоНазначения.РазложитьСтрокуВМассивПодстрок(РекомендуемаяВерсияПлатформы(), ".");
	
	Для Счетчик = РекомендуемаяВерсия.Количество() + 1 По ТекущаяВерсия.Количество() Цикл
		РекомендуемаяВерсия.Добавить("0");
	КонецЦикла;
	
	ВерсияПодходит = Истина;
	Для Счетчик = 0 По ТекущаяВерсия.ВГраница() Цикл
		Текущая = Число(ТекущаяВерсия[Счетчик]);
		Рекомендуемая = ?(ПустаяСтрока(РекомендуемаяВерсия[Счетчик]), 0, Число(РекомендуемаяВерсия[Счетчик]));
		Если Текущая > Рекомендуемая Тогда
			Прервать;
		ИначеЕсли Текущая < Рекомендуемая Тогда
			ВерсияПодходит = Ложь;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Если ВерсияПодходит Тогда
		Возврат;
	КонецЕсли;
	
	Если Вопрос("Для работы с данной конфигурацией требуется версия платформы 1С:Предприятие " + 
		РекомендуемаяВерсияПлатформы() + " или более поздняя." + 
		Символы.ПС + "Используемая сейчас версия - " + СистемнаяИнформация.ВерсияПриложения + "." + 
		Символы.ПС + "Рекомендуется прекратить работу программы и обновить версию платформы 1С:Предприятие. В противном случае некоторые функции программы будут недоступны или будут работать неправильно." + 
		Символы.ПС + 
		Символы.ПС + "Для получения новой версии платформы 1С:Предприятие воспользуйтесь разделом сайта фирмы ""1С"" для пользователей (http://users.v8.1c.ru) или диском Информационно-технологического сопровождения (ИТС)" + 
		Символы.ПС + 
		Символы.ПС + "Прекратить работу программы?", РежимДиалогаВопрос.ДаНет) = КодВозвратаДиалога.Да Тогда
		
		ПрекратитьРаботуСистемы();
		
	КонецЕсли;
			
КонецПроцедуры

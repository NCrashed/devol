/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module devol.std.random;

import std.array;
import std.algorithm;
import std.random;
import std.stdio;
import std.math;
import std.conv;

/// Вызов одной из функций с определенным шансом
/**
 * Вызывает один из переданных делегатов в зависимости от распределения 
 * вероятностей.
 * @note Сумма вероятностей должна быть равна единице!
 * @param range массив вероятностей выбора итого делегата
 * @param funcs перечисление делегатов
 */
void randomRange(T...)(double[] range, T funcs)
in
{
	double summ = 0;
	foreach( val; range )
	{
		summ += val;
	}
	assert(abs(summ-1) <= 0.001, text("Сумма вероятностей должна быть равна 1! А не ", summ));
	assert(range.length == funcs.length, "Размерности массивов вероятностей и делегатов не совпадают!");
}
body
{
	double chance = uniform!"[]"(0.,1.);
	double begin = 0, end = 0;
	
	foreach(int i, f; funcs )
	{
		end += range[i];
		
		if (  begin < chance && chance <= end )
		{
			return f();
		}
		begin = end;
	}
}

/// Выбор одного из варианта по набору вероятностей
/**
 * Вызывает функцию и передает ей номер выбранной вероятности.
 * @note Сумма вероятностей должна быть равна единице!
 * @param range массив вероятностей
 * @param funcs перечисление делегатов
 */
void randomRange(alias T)(double[] range)
	if(__traits(compiles, "T(0);"))
in
{
	double summ = 0;
	foreach( val; range )
	{
		summ += val;
	}
	assert(abs(summ-1) <= 0.001, text("Сумма вероятностей должна быть равна 1! А не ", summ));
}
body
{
	double chance = uniform!"[]"(0.,1.);
	double begin = 0, end = 0;
	
	foreach(int i, val; range )
	{
		end += val;
		
		if (begin < chance && chance <= end )
		{
			return T(i);
		}
		begin = end;
	}
}


/// Статистический тест randomRange
unittest
{
	int count = 500000;
	double a = 0;
	double b = 0;
	
	foreach(i; 1..count)
	{
		randomRange([0.5, 0.5],
			{
				a++;
			},
			{
				b++;
			}
		); 
	}
	a = a/count;
	b = b/count;
	assert(abs(a-0.5) <= 0.01, text("randomRange не прошла статистический тест da = ", abs(a-0.5)));
	assert(abs(b-0.5) <= 0.01, text("randomRange не прошла статистический тест db = ", abs(b-0.5)));
}

/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module devol.programtype;

public
{
	import devol.individ;
	import devol.world;
	import devol.line;
}
private
{
	import std.math;
	import std.string;
}

interface ProgTypeAbstract
{
	/// Минимальный размер программы при генерации
	@property uint progMinSize()
	in
	{
		assert(progMinSize() <= progMaxSize(), "Min program size is greater then max program size!");
	}
	
	/// Максимальный размер программы при генерации
	@property uint progMaxSize()
	in
	{
		assert(progMinSize() <= progMaxSize(), "Min program size is greater then max program size!");
	}
	
	/// Минимальный размер секции при генерации	
	@property uint scopeMinSize()
	in
	{
		assert(scopeMinSize() <= scopeMaxSize(), "Min scope size is greater then max scope size!");
	}
	
	/// Максимальный размер секции при генерации
	@property uint scopeMaxSize()
	in
	{
		assert(scopeMinSize() <= scopeMaxSize(), "Min scope size is greater then max scope size!");
	}
	
	/// Шанс сгененрировать новую подлинию при генерации
	@property float newOpGenChance()
	in
	{
		assert(abs(newOpGenChance()+newScopeGenChance()+newLeafGenChance()-1) < 0.01, "Generation summed chance isn't 1!");
	}
	out(result)
	{
		assert( 0 <= result && result <= 1, "Return value isn't a probability!");
	}
	
	/// Шанс сгенерировать новую подсекцию при генерации
	@property float newScopeGenChance()
	in
	{
		assert(abs(newOpGenChance()+newScopeGenChance()+newLeafGenChance()-1) < 0.01, "Generation summed chance isn't 1!");
	}
	out(result)
	{
		assert( 0 <= result && result <= 1, "Return value isn't a probability!");
	}
	
	/// Шанс сгенерировать новый аргумент при генерации
	@property float newLeafGenChance()
	in
	{
		assert(abs(newOpGenChance()+newScopeGenChance()+newLeafGenChance()-1) < 0.01, "Generation summed chance isn't 1!");
	}
	out(result)
	{
		assert( 0 <= result && result <= 1, "Return value isn't a probability!");
	}
	
	/// Шанс изменения значения листа программы
	@property float mutationChangeChance()
	in
	{
		assert(abs(mutationChangeChance()+mutationReplaceChance()+mutationDeleteChance()-1) < 0.01, "Generation summed chance isn't 1!");
	}
	out(result)
	{
		assert( 0 <= result && result <= 1, "Return value isn't a probability!");
	}
	
	/// Шанс замены узла программы на подлинию
	@property float mutationReplaceChance()
	in
	{
		assert(abs(mutationChangeChance()+mutationReplaceChance()+mutationDeleteChance()-1) < 0.01, "Generation summed chance isn't 1!");
	}
	out(result)
	{
		assert( 0 <= result && result <= 1, "Return value isn't a probability!");
	}
	
	/// Шанс удаление узла программы и замены его листом
	@property float mutationDeleteChance()
	in
	{
		assert(abs(mutationChangeChance()+mutationReplaceChance()+mutationDeleteChance()-1) < 0.01, "Generation summed chance isn't 1!");
	}
	out(result)
	{
		assert( 0 <= result && result <= 1, "Return value isn't a probability!");
	}
	
	/// Шанс добавления новой линии в программе
	@property float mutationAddLineChance()
	in
	{
		assert(mutationAddLineChance()+mutationRemoveLineChance() <= 1, "Mutation summ chance of add/remove line is greater 1!");
	}
	out(result)
	{
		assert( 0 <= result && result <= 1, "Return value isn't a probability!");
	}
		
	/// Шанс удаления линии в программе
	@property float mutationRemoveLineChance()
	in
	{
		assert(mutationAddLineChance()+mutationRemoveLineChance() <= 1, "Mutation summ chance of add/remove line is greater 1!");
	}
	out(result)
	{
		assert( 0 <= result && result <= 1, "Return value isn't a probability!");
	}
		
	/// Максимальный модуль изменения значений для числовых типов
	@property string maxMutationChange()
	out(result)
	{
		assert(isNumeric(result), "Mutation change must be a numeric string!");
	}
	
	/// Шанс провести операцию мутации над индивидом
	@property float mutationChance()
	in
	{
		assert( abs( mutationChance()+crossingoverChance() - 1) < 0.01, "Summ of mutattion and crossingover chances isn't 1.0!");
	}
	out(result)
	{
		assert( 0 <= result && result <= 1, "Return value isn't a probability!");
	}
	
	/// Шанс провести операцию кроссинговера над индивидом
	@property float crossingoverChance()
	out(result)
	{
		assert( 0 <= result && result <= 1, "Return value isn't a probability!");
	}
	
	/// Часть популяции из лучших индивидов, которые будут скопированы в следующее поколение
	@property float copyingPart()
	out(result)
	{
		assert( 0 <= result && result <= 1, "Return value must be in range [0,1]!");
	}
	
	/// Оценка результата работы индивида
	double getFitness(IndAbstract pInd, WorldAbstract pWorld, double time);
	
	/// Инициализация входных значений для индивида
	Line[] initValues(WorldAbstract pWorld);
}


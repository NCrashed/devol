/**
*   Copyright: © 2012-2014 Anton Gushcha
*   License: Subject to the terms of the MIT license, as written in the included LICENSE file.
*   Authors:  NCrashed <ncrashed@gmail.com>,
*             LeMarwin <lemarwin42@gmail.com>,
*             Nazgull09 <nazgull90@gmail.com>
*/
module devol.evolutor;

import std.random;
import std.stdio;
import std.array;
import std.math;
import std.conv;
import std.array;
import std.algorithm;
import devol.typemng;
import devol.operatormng;
import devol.std.random;
import devol.population;

/// Статистический тест случайного выбора элемента
enum RANDOM_ELEM_STAT_TEST = 0;
/// Статистический тест случайного выбора листа
enum RANDOM_LEAF_STAT_TEST = 0;
/// Тест замены случайного элемента
enum RANDOM_ELEM_REPLACE_TEST = 0;
/// Тест обмена случайными элементами
enum RANDOM_ELEM_SWAP_TEST = 0;
/// Тест мутации
enum MUTATION_TEST = 0;
/// Тест кроссинговера
enum CROSSINGOVER_TEST = 0;

public
{
	import devol.std.typepod;
	import devol.programtype;
}
	
class Evolutor
{
	class GenExeption : Exception
	{
		ErrorType error;
		Type t;
		
		enum ErrorType
		{
			SEARCH_OPERATOR
		}
		
		this(string s, ErrorType errt, Type et)
		{
			super(s);
			error = errt;
			t = et;
		}
	}
	
	static int MaxProgramDepth = 30;
	
	static bool getChance(float val)
	{
		return uniform!"[]"(0.0,1.0) <= val;
	}
	
	void generateInitProgram(IndAbstract pInd, ProgTypeAbstract ptype)
	{
		Line[] buff = new Line[0];
		foreach(i; 0..uniform!("[]")(ptype.progMinSize,ptype.progMaxSize))
		{
			buff ~= generateLine( pInd, ptype );
		}
		pInd.program = buff;
	}
	
	/// Генерация линии
	Line generateLine( IndAbstract pInd, ProgTypeAbstract ptype )
	{
		auto line = new Line();
		auto opmng = OperatorMng.getSingleton();
		auto tmng = TypeMng.getSingleton();
		auto scopetype = cast(TypeScope)(tmng.getType("TypeScope"));
		auto voidtype = cast(TypeVoid)(tmng.getType("TypeVoid"));
		
		auto op = opmng.getRndOperator();
		if (op is null) return line;
		
		line.operator = op;
		
		uint i = 0; 
		foreach( j,arg; line )
		{
			if (arg.type.name == voidtype.name && getChance(ptype.newScopeGenChance))
			{
				auto ascope = scopetype.getNewArg();
				uint s = uniform!"[]"(ptype.scopeMinSize, ptype.scopeMaxSize);
				scope(success) line[j] = ascope;
				
				writeln("Generating scope");
				foreach(i; 0..s)
				{
					try
					{
						ascope.addElement( generateLine( pInd, ptype, voidtype ) );
					} catch( GenExeption e)
					{
						if (e.error == e.ErrorType.SEARCH_OPERATOR)
							debug writeln("Note: cannot find operator for type ", e.t.name);
					}
				}
			} else if (getChance(ptype.newOpGenChance) 
					|| (op.style == ArgsStyle.CONTROL_STYLE && i != 0) )
			{
				auto aline = new Line;
				scope(success) line[j] = aline;
				try
				{
					aline = generateLine( pInd, ptype, arg.type );
				} catch( GenExeption e)
				{
					if (e.error == e.ErrorType.SEARCH_OPERATOR)
						debug writeln("Note: cannot find operator for type ", e.t.name);
					
				}		
			} 
			
			i++;
		}
		
		return line;
	}
	
	/// Генерация типизированной линии
	Line generateLine( IndAbstract pInd, ProgTypeAbstract ptype, 
		Type rtype, uint depth = 0)
	{
		auto line = new Line();
		auto opmng = OperatorMng.getSingleton();
		auto tmng = TypeMng.getSingleton();
		auto scopetype = cast(TypeScope)(tmng.getType("TypeScope"));
		auto voidtype = cast(TypeVoid)(tmng.getType("TypeVoid"));		
		
		Operator op;
		if ( cast(TypeLine)rtype is null && cast(TypeScope)rtype is null )
		{
			op = opmng.getRndOperator(rtype);
			if (op is null) 
			{
				throw new Evolutor.GenExeption(
				"Cannot choose operator for type " ~ rtype.name, 
				GenExeption.ErrorType.SEARCH_OPERATOR,
				rtype
				);
			}
		} else
		{
			debug writeln("Type is container, generating any op.");
			op = opmng.getRndOperator();
			if (op is null) 
			{
				throw new Evolutor.GenExeption(
				"Cannot choose operator for any type! May be there aren't any one?", 
				GenExeption.ErrorType.SEARCH_OPERATOR,
				rtype
				);
			}
		}
		
		line.operator = op;
		
		if (depth >= MaxProgramDepth) return line;
		
		uint i = 0;
		foreach( i,arg; line )
		{
			if (arg.type.name == voidtype.name && getChance(ptype.newScopeGenChance))
			{
				auto ascope = scopetype.getNewArg();
				uint s = uniform!"[]"(ptype.scopeMinSize, ptype.scopeMaxSize);
				
				foreach(j; 0..s)
				{
					ascope.addElement( generateLine( pInd, ptype, voidtype, depth+1 ) );
				}	
				line[i] = ascope;		
			} else if (getChance(ptype.newOpGenChance)
					|| (op.style == ArgsStyle.CONTROL_STYLE && i != 0) ) 
			{
				auto aline = new Line;
				aline = generateLine( pInd, ptype, arg.type,
					depth+1 );
				line[i] = aline;
			}
			i++;
		}
		return line;		
	}
	
	/// Получение случайного элемента дерева. Равномерное распределение.
	/**
	 * Вероятности выбрать любой элемент дерева будет равные. Данный метод
	 * не подойдет, если нужно заменить элемента дерева.
	 * @param cont Узел дерева, в котором нужно выбрать.
	 * @see replaceRandomElementStd
	 */
	Argument getRandomElementStd(Container cont)
	{
		auto chances = new double[0];
		Argument ret = null;
		
		do
		{
			ulong childs = cont.children;
			
			chances ~= 1./childs;
			foreach( arg; cont )
			{
				chances ~= cast(double)arg.children/cast(double)childs;
			}
			
			randomRange!(
				(int k)
				{
					if (k==0)
						ret = cont;
					else
						if (cast(Container)(cont[k-1]) is null)
							ret = cont[k-1];
						else 
							cont = cast(Container)(cont[k-1]);
				}
				)(chances);
				
			chances.clear();	
		} while(ret is null);
		
		return ret;
	}
	
	/// Замена случайного элемента дерева. Равномерное распределение.
	/**
	 * Вероятности заменить любой элемент дерева будет равные. 
	 * @note Данный метод не подходит для замены самого первого переданного узла, его
	 * замену реализует пользователь этого метода отдельно.
	 * @param cont Узел дерева, в котором нужно заменить.
	 * @param generator Делегат-генератор, делегат, который создаст типизированный аргумент.
	 */
	void replaceRandomElementStd(Container cont, Argument delegate(Type) generator)
	{
		auto chances = new double[0];
		bool end = false;
		Container prevCont = null;
		uint prevContI = -1;
		
		do
		{
			ulong childs = cont.children;
			
			chances ~= 1./childs;
			foreach( arg; cont )
			{
				chances ~= cast(double)arg.children/cast(double)childs;
			}
			
			randomRange!(
				(int k)
				{
					if (k==0)
					{
						if (prevCont !is null)
						{
							Type t;
							if (cast(Line)(prevCont[prevContI]) !is null)
							{
								auto line = cast(Line)(prevCont[prevContI]);
								t = line.operator.rtype;
							}
							else if (cast(ArgScope)(prevCont[prevContI]) !is null)
								t = new TypeVoid;							
							prevCont[prevContI] = generator(t);
						}
						end = true;
					}
					else
						if (cast(Container)(cont[k-1]) is null)
						{
							cont[k-1] = generator(cont[k-1].type);
							end = true;
						}
						else 
						{
							prevCont = cont;
							prevContI = k-1;
							cont = cast(Container)(cont[k-1]);
						}
				}
				)(chances);
				
			chances.clear();	
		} while(!end);	
	}
	
	/// Получение случайного листа по равномерному распределению
	/**
	 * Вероятность выбрать любой лист дерева будет одинаковой.
	 */
	Argument getRandomLeafStd(Container cont)
	{
		bool normalize( ref double[] mass )
		{
			if (mass.length == 0) return false;
			
			double summ = 0;
			foreach( val; mass)
				summ += val;
			
			if (summ == 0)
				return false;
				
			foreach( ref val; mass)
				val /= summ;
			return true;
		}
		
		auto chances = new double[0];
		Argument ret = null;
		
		do
		{
			ulong leafs = cont.leafs;
			
			foreach( arg; cont )
			{
				chances ~= cast(double)arg.leafs/cast(double)leafs;
			}
			if (!normalize(chances))
			{
				return null;
			}
			debug writeln("Распределение вероятностей по листам: ", chances);
			
			randomRange!(
				(int k)
				{
					if (cast(Container)(cont[k]) is null)
						ret = cont[k];
					else 
						cont = cast(Container)(cont[k]);
				}
				)(chances);
				
			chances.clear();	
		} while(ret is null);
		
		return ret;		
	}
	
	/// Обмен элементами между деревьями
	/**
	 * Выбирается поддерево из каждого контейнера и меняются местами. Выбор
	 * идет на основе равномерного распределения.
	 * @param cont1 Первый контейнер
	 * @param cont2 Второй контейнер
	 * @note Обмен корневыми элементами невозможен в рамках данного метода,
	 * его реализацей занимайтесь сами.
	 */
	bool swapRandomElements(Container cont1, Container cont2, ProgTypeAbstract ptype)
	{
		bool validType(Argument a, Argument b)
		{
			if (cast(ArgScope)a !is null && cast(ArgScope)b !is null)
				return true;
			else if (cast(Line)a !is null && cast(ArgScope)b !is null)
				return (cast(Line)a).operator.rtype.name == "TypeVoid";
			else if (cast(Line)b !is null && cast(ArgScope)a !is null)
				return (cast(Line)b).operator.rtype.name == "TypeVoid";
			else if (cast(Line)a !is null && cast(Line)b !is null)
				return (cast(Line)a).operator.rtype == (cast(Line)b).operator.rtype;
			else 
				return a.type == b.type;
			
		}
		
		struct SwapStruct
		{
			Container parentCont;
			uint place;
		}
		/// Формирование массива возможных замен
		SwapStruct[] checkExistens(Container checkCont, Argument swapArg)
		{
			auto ret = new SwapStruct[0];
			uint i = 0;
			foreach(Argument arg; checkCont )
			{
				if (cast(Container)(arg) !is null)
				{
					if ( (cast(Line)(arg) !is null && (cast(Line)arg).operator.rtype.name == swapArg.type.name) ||
						 (cast(ArgScope)arg !is null  && cast(ArgScope)swapArg !is null) )
					{	
						SwapStruct st;
						st.parentCont = checkCont;
						st.place = i;
						ret ~= st;
					}
					ret ~= checkExistens( cast(Container)(arg), swapArg);
				}
				else
					if ( arg.type.name == swapArg.type.name )
					{
						SwapStruct st;
						st.parentCont = checkCont;
						st.place = i;						
						ret ~= st;
					}
				i++;
			}
			return ret;
		}
		
		/// Поиск второго подходящего поддерева и обмен.
		bool innerSwap( Container parentCont, int place )
		{
			auto candidates = checkExistens( cont2, parentCont[place] );
			if (candidates.length == 0) return false;
			
			auto candidate = candidates[uniform(0,candidates.length)];
			auto temp = parentCont[place];
			parentCont[place] = candidate.parentCont[candidate.place];
			candidate.parentCont[candidate.place] = temp;
			return true;
		}
		

			auto chances = new double[0];
			bool end = false;
			Container cont = cont1;
			Container prevCont = null;
			uint prevContI = -1;

			
			do
			{
				ulong childs = cont.children;
				
				chances ~= 1./childs;
				foreach( arg; cont )
				{
					chances ~= cast(double)arg.children/cast(double)childs;
				}
				
					randomRange!(
						(int k)
						{
							if (k==0)
							{
								debug writeln("Selected to stop. Finded 1st tree");
								if (prevCont !is null)
								{
									innerSwap(prevCont, prevContI);
								}
								end = true;
							}
							else
								if (cast(Container)(cont[k-1]) is null)
								{
									debug writeln("Selected leaf. Finded 1st tree");
									innerSwap(cont, k-1);
									
									end = true;
								}
								else 
								{
									debug writeln("Going down");
									prevCont = cont;
									prevContI = k-1;
									cont = cast(Container)(cont[k-1]);
								}
						}
						)(chances);	
				chances.clear();	
			} while(!end);	

		return true;
	}
	
	/// Стандартная мутация
	void mutationStd( IndAbstract pInd, ProgTypeAbstract ptype)
	{
		if (pInd.program.length == 0) return;
		
		size_t k = uniform(0, pInd.program.length);
		Line line = pInd.program[k];
		auto chances = new double[3];
		
		/// Сначала проверим на глобальную мутацию
		chances[0] = ptype.mutationAddLineChance();
		chances[1] = ptype.mutationRemoveLineChance();
		chances[2] = 1 - chances[0] - chances[1];
		
		bool local = false;
		randomRange!(
			(int k)
			{
				if (k==0) // mutationAddLineChance
				{
					pInd.program = pInd.program ~ generateLine(pInd, ptype);
					return;
				} else if (k==1) // mutationRemoveLineChance
				{
					if( k != pInd.program.length -1)
						pInd.program = pInd.program[0..k] ~ pInd.program[k+1..$];
					else
						pInd.program = pInd.program[0..k];
					return;
				}
				local = true;
			}
		)(chances);
		
		if (!local) return;
		/// Локальная мутация
		chances[0] = ptype.mutationChangeChance();
		chances[1] = ptype.mutationReplaceChance();
		chances[2] = ptype.mutationDeleteChance();
		
		debug writeln("Mutation chances: ", chances);
		
		randomRange!(
			(int t)
			{
				switch(t)
				{
					case 0: // mutationChangeChance
					{
						debug writeln("Change");
						if (line.length > 0 && line.leafs > 0)
						{
							auto arg = getRandomLeafStd(line);
							if (arg !is null)
								arg.randomChange(ptype.maxMutationChange);
						}
						break;
					}
					case 1: // mutationReplaceChance
					{
						debug writeln("Replace");
						if ( line.children > 1 )
							replaceRandomElementStd(line, 
								(Type t)
								{
									return cast(Argument)generateLine(pInd, ptype, t);
								});
							
						break;
					}
					case 2: // mutationDeleteChance
					{
						debug writeln("Delete");
						replaceRandomElementStd(line, 
							(Type t)
							{
								Argument arg = t.getNewArg();
								arg.randomChange(ptype.maxMutationChange);
								return arg;
							});
						break;
					}
					default:
				}
			}
		)(chances);
	}
	
	/// Стандартный кроссинговер
	bool crossingoverStd(IndAbstract pIndA, IndAbstract pIndB, ProgTypeAbstract ptype)
	{
		if (pIndA.program.length == 0 || pIndB.program.length == 0) return false;
		debug writeln("Starting crossingover");
		
		ulong length = pIndA.program.length;
		if (pIndB.program.length < length)
			length = pIndB.program.length;
		debug writeln("Selected length:", length);
			
		foreach(ulong i; 0..length/2+1)
		{
			debug writeln("Starting ",i," swapping");
			size_t kA = uniform(0,pIndA.program.length);
			size_t kB = uniform(0,pIndB.program.length);
			Line lineA = pIndA.program[kA];
			Line lineB = pIndB.program[kB];
			
			/// Перемена местами двух деревьев полностью
			if ( uniform!"[]"(0,1) < 1./cast(double)(lineA.children+lineB.children))
			{
				debug writeln("Swapping roots");
				swap(pIndA.program[kA], pIndB.program[kB]);
			} else /// Обмен поддеревьями
			{
				debug writeln("Swapping subtrees");
				if (!swapRandomElements( lineA, lineB, ptype ))
					return false;
				
			}
		}
		return true;
	}
	 
	/// Создание следующей популяции
	/**
	 * 	Создание популяции на основе вычисленной приспособленности.
	 *  @param pop Популяция, из которой будет браться материал для 
	 * 	следующей популяции.
	 * 	@param ptype Тип программы, в котором записаны все настройки
	 *  процесса эволюции.
	 *  @return Новая популяция.
	 */
	PopType formNextPopulation(PopType)(PopType pop, ProgTypeAbstract ptype)
	{
		if (pop.length == 0) return pop;
		
		//Вычисляем среднюю приспособленность
		debug writeln("Вычисляем сумму приспособленность: ");
		double averFitness = 0;
		foreach( ind; pop)
			averFitness += ind.fitness;
		
		auto newPop = pop.dup;
		newPop.clear();
		debug writeln( "averFitness = ", averFitness );
		
		// Копируем лучших индивидов
		debug writeln("Копируем лучших индивидов");
		int k = cast(int)round((ptype.copyingPart()*pop.length));
		debug writeln("Будет выбрано ", k, " лучших муравьев");
		
		auto sortedInds = new pop.IndividType[0];
		foreach( ind; pop)
			sortedInds ~= cast(pop.IndividType)ind;
		
		sort!("a.fitness > b.fitness")(sortedInds);
		foreach(i; 0..k)
		{
			debug writeln("Добавляем ", i, " из лучших");
			newPop.addIndivid(cast(newPop.IndividType)(sortedInds[i].dup));
		}
				
		debug
		{
			 write("Отсортированные индивиды по фитнес: [");
			 foreach(ind; sortedInds)
				write(ind.fitness,",");
			 writeln("]");
			 writeln("Размер новой популяции ", newPop.length);
		}
		// Формируем шансы для операций
		auto opChances = new double[2];
		opChances[0] = ptype.mutationChance();
		opChances[1] = ptype.crossingoverChance();
		debug writeln("Шансы на операции: ", opChances);
		
		// Формируем шансы индивидов
		auto indChances = new double[0];
		foreach( ind; pop )
		{
			indChances ~= cast(double)(ind.fitness)/cast(double)(averFitness);
		}
		debug writeln("Шансы индивидов: ", indChances);
		
		debug writeln("Начинаем формировать новую популяцию:");
		while( newPop.length < pop.length )
		{
			int opSelected;
			randomRange!((int m){opSelected = m;})(opChances);
			
			if (opSelected == 0) // mutationChance
			{
				debug writeln("Выбрана мутация");
				randomRange!(
					(int s)
					{
						debug writeln("Выбран индивид №", s);
						auto ind = cast(pop.IndividType)pop[s].dup;
						debug writeln("Был: ", ind.programString());
						mutationStd( ind, ptype);
						debug writeln("Стал: ", ind.programString());
						newPop.addIndivid( ind );
					}
				)(indChances);
			} else // crossingoverChance
			{
				// Замечен странный баг с вложенными лямбдами, поэтому передаю занчения вверх
				debug writeln("Выбран кроссинговер");
				int iInd1;
				int iInd2;
				randomRange!((int s1){iInd1 = s1;})(indChances);
				randomRange!((int s2){iInd2 = s2;})(indChances);
				auto pIndA = cast(pop.IndividType)pop[iInd1].dup;
				auto pIndB = cast(pop.IndividType)pop[iInd2].dup;
				
				debug writeln("Выбраны индивиды №", iInd1, " и №", iInd2);
				debug writeln("Был: ", pIndA.programString());
				debug writeln("Был: ", pIndB.programString());
				crossingoverStd(pIndA, pIndB, ptype);
				debug writeln("Стал: ", pIndA.programString());
				debug writeln("Стал: ", pIndB.programString());
				
				newPop.addIndivid( pIndA );
				if (newPop.length < pop.length)
					newPop.addIndivid( pIndB );				
			}
		}
		return newPop;
	}
} 

//======================================================================
//							Статистические тесты
//======================================================================
static if (RANDOM_ELEM_STAT_TEST)
{
	unittest 
	{
		import std.process;
		class VoidOp : Operator
		{
			this()
			{
				mRetType = new TypePod!int;
				super("v","",ArgsStyle.CLASSIC_STYLE);
				
				ArgInfo a1;
				a1.type = mRetType;
				a1.min = "-1000";
				a1.max = "+1000";
				
				args ~= a1;
				args ~= a1;
				args ~= a1;
			}
		
			Argument apply(IndAbstract ind, Line line, WorldAbstract world)
			{
				auto arg = mRetType.getNewArg();
				return arg;
			}	
		
		}
		
			auto tm = new TypeMng;
			auto em = new Evolutor;
			tm.registerType!(TypePod!int);
			
			auto op = new VoidOp;
			auto nline0 = new Line;
			auto nline1 = new Line;
			auto nline2 = new Line;
			auto nline3 = new Line;

			
			nline0.operator = op;
			nline1.operator = op;
			nline2.operator = op;
			nline3.operator = op;
			
			nline0[0] = nline1;
			nline0[1] = op.mRetType.getNewArg("1","1",[]);
			nline0[2] = op.mRetType.getNewArg("2","2",[]);
			
			nline1[0] = op.mRetType.getNewArg("3","3",[]);
			nline1[1] = nline2;
			nline1[2] = nline3;
			
			nline2[0] = op.mRetType.getNewArg("4","4",[]);
			nline2[1] = op.mRetType.getNewArg("5","5",[]);
			nline2[2] = op.mRetType.getNewArg("6","6",[]);
			
			nline3[0] = op.mRetType.getNewArg("7","7",[]);
			nline3[1] = op.mRetType.getNewArg("8","8",[]);
			nline3[2] = op.mRetType.getNewArg("9","9",[]);
			
			double[Argument] stat;
			
			foreach(arg; nline0)
				stat[arg] = 0;
			foreach(arg; nline1)
				stat[arg] = 0;
			foreach(arg; nline2)
				stat[arg] = 0;
			foreach(arg; nline3)
				stat[arg] = 0;
				
			Argument a;
			ProgTypeAbstract ptype;
			ulong count = cast(ulong)1e6;
			
			foreach(ulong i; 0..count)
			{
				version(linux)
					system("clear");
					
				a = em.getRandomElementStd(nline0);
				stat[a] += 1.;
				
				foreach(key,val; stat)
				{
					writeln(key.tostring, " : ", val/i);
				}
				writeln( "Выполнено ", cast(double)i/count*100, "%");
			}
			version(linux)
				system("clear");
			writeln("Результаты теста: ");
			foreach(key,val; stat)
			{
				writeln(key.tostring, " : ", val/count);
			}
			getchar();
	}
}

static if (RANDOM_ELEM_REPLACE_TEST)
{
	unittest 
	{
		import std.process;
		import ant.progtype;
			
		class VoidOp : Operator
		{
			this()
			{
				mRetType = new TypePod!int;
				super("v","",ArgsStyle.CLASSIC_STYLE);
				
				ArgInfo a1;
				a1.type = mRetType;
				a1.min = "-1000";
				a1.max = "+1000";
				
				args ~= a1;
				args ~= a1;
				args ~= a1;
			}
		
			Argument apply(IndAbstract ind, Line line, WorldAbstract world)
			{
				auto arg = mRetType.getNewArg();
				return arg;
			}	
		
		}
		
			auto tm = new TypeMng;
			auto em = new Evolutor;
			//tm.registerType!(TypePod!int);
		
			AntProgType ptype = new AntProgType();
			Ant pInd = new Ant();
			
			auto op = new VoidOp;
			auto nline0 = new Line;
			auto nline1 = new Line;
			auto nline2 = new Line;
			auto nline3 = new Line;

			
			nline0.operator = op;
			nline1.operator = op;
			nline2.operator = op;
			nline3.operator = op;
			
			nline0[0] = nline1;
			nline0[1] = op.mRetType.getNewArg("1","1",[]);
			nline0[2] = op.mRetType.getNewArg("2","2",[]);
			
			nline1[0] = op.mRetType.getNewArg("3","3",[]);
			nline1[1] = nline2;
			nline1[2] = nline3;
			
			nline2[0] = op.mRetType.getNewArg("4","4",[]);
			nline2[1] = op.mRetType.getNewArg("5","5",[]);
			nline2[2] = op.mRetType.getNewArg("6","6",[]);
			
			nline3[0] = op.mRetType.getNewArg("7","7",[]);
			nline3[1] = op.mRetType.getNewArg("8","8",[]);
			nline3[2] = op.mRetType.getNewArg("9","9",[]);
				
			//pInd.program[0] = nline0;
			char ans;
			
			do
			{
				version(linux)
					system("clear");
				
				writeln("Было: ");
				writeln(nline0.tostring);	
				em.replaceRandomElementStd(nline0, (Type t){return cast(Argument)em.generateLine(pInd, ptype, t);});
				//em.replaceRandomElementStd(nline0, (Type t){return new ArgVoid;});
				writeln("Стало: ");
				writeln(nline0.tostring);
				
				write("Для остновки введите 'n': ");
				ans = readln()[0];
			} while(ans != 'n' && ans != 'N');

	}
}

static if (RANDOM_LEAF_STAT_TEST)
{
	unittest 
	{
		import std.process;
		class VoidOp : Operator
		{
			this()
			{
				mRetType = new TypePod!int;
				super("v","",ArgsStyle.CLASSIC_STYLE);
				
				ArgInfo a1;
				a1.type = mRetType;
				a1.min = "-1000";
				a1.max = "+1000";
				
				args ~= a1;
				args ~= a1;
				args ~= a1;
			}
		
			Argument apply(IndAbstract ind, Line line, WorldAbstract world)
			{
				auto arg = mRetType.getNewArg();
				return arg;
			}	
		
		}
		
			auto tm = new TypeMng;
			auto em = new Evolutor;
			tm.registerType!(TypePod!int);
			
			auto op = new VoidOp;
			auto nline0 = new Line;
			auto nline1 = new Line;
			auto nline2 = new Line;
			auto nline3 = new Line;

			
			nline0.operator = op;
			nline1.operator = op;
			nline2.operator = op;
			nline3.operator = op;
			
			nline0[0] = nline1;
			nline0[1] = op.mRetType.getNewArg("1","1",[]);
			nline0[2] = op.mRetType.getNewArg("2","2",[]);
			
			nline1[0] = op.mRetType.getNewArg("3","3",[]);
			nline1[1] = nline2;
			nline1[2] = nline3;
			
			nline2[0] = op.mRetType.getNewArg("4","4",[]);
			nline2[1] = op.mRetType.getNewArg("5","5",[]);
			nline2[2] = op.mRetType.getNewArg("6","6",[]);
			
			nline3[0] = op.mRetType.getNewArg("7","7",[]);
			nline3[1] = op.mRetType.getNewArg("8","8",[]);
			nline3[2] = op.mRetType.getNewArg("9","9",[]);
			
			double[Argument] stat;
			
			foreach(arg; nline0)
				stat[arg] = 0;
			foreach(arg; nline1)
				stat[arg] = 0;
			foreach(arg; nline2)
				stat[arg] = 0;
			foreach(arg; nline3)
				stat[arg] = 0;
				
			Argument a;
			ProgTypeAbstract ptype;
			ulong count = cast(ulong)1e6;
			
			foreach(ulong i; 0..count)
			{
				version(linux)
					system("clear");
					
				a = em.getRandomLeafStd(nline0);
				stat[a] += 1.;
				
				foreach(key,val; stat)
				{
					writeln(key.tostring, " : ", val/i);
				}
				writeln( "Выполнено ", cast(double)i/count*100, "%");
			}
			version(linux)
				system("clear");
			writeln("Результаты теста: ");
			foreach(key,val; stat)
			{
				writeln(key.tostring, " : ", val/count);
			}
			getchar();
	}
}

static if (RANDOM_ELEM_SWAP_TEST)
{
	unittest 
	{
		import std.process;
		import ant.progtype;
			
		class VoidOp : Operator
		{
			this()
			{
				mRetType = new TypePod!int;
				super("v","",ArgsStyle.CLASSIC_STYLE);
				
				ArgInfo a1;
				a1.type = mRetType;
				a1.min = "-1000";
				a1.max = "+1000";
				
				args ~= a1;
				args ~= a1;
				args ~= a1;
			}
		
			Argument apply(IndAbstract ind, Line line, WorldAbstract world)
			{
				auto arg = mRetType.getNewArg();
				return arg;
			}	
		
		}
		
			auto tm = new TypeMng;
			auto em = new Evolutor;
			//tm.registerType!(TypePod!int);
		
			AntProgType ptype = new AntProgType();
			Ant pInd = new Ant();
			
			auto op = new VoidOp;
			auto nline0 = new Line;
			auto nline1 = new Line;
			auto nline2 = new Line;
			auto nline3 = new Line;

			
			nline0.operator = op;
			nline1.operator = op;
			nline2.operator = op;
			nline3.operator = op;
			
			nline0[0] = nline1;
			nline0[1] = op.mRetType.getNewArg("1","1",[]);
			nline0[2] = op.mRetType.getNewArg("2","2",[]);
			
			nline1[0] = op.mRetType.getNewArg("3","3",[]);
			nline1[1] = nline2;
			nline1[2] = nline3;
			
			nline2[0] = op.mRetType.getNewArg("4","4",[]);
			nline2[1] = op.mRetType.getNewArg("5","5",[]);
			nline2[2] = op.mRetType.getNewArg("6","6",[]);
			
			nline3[0] = op.mRetType.getNewArg("7","7",[]);
			nline3[1] = op.mRetType.getNewArg("8","8",[]);
			nline3[2] = op.mRetType.getNewArg("9","9",[]);
				
			pInd.program = pInd.program ~ nline0;
			char ans;
			
			Line lineA = nline0;
			Line lineB = nline0.dup;
			
			do
			{
				version(linux)
					system("clear");
				
				writeln("Было: ");
				writeln("Линия А: ", lineA.tostring);	
				writeln("Линия B: ", lineB.tostring);
					
				em.swapRandomElements( lineA, lineB, ptype );
				//em.mutationStd(pInd, ptype);
				
				writeln("Стало: ");
				writeln("Линия А: ", lineA.tostring);	
				writeln("Линия B: ", lineB.tostring);
				
				write("Для остновки введите 'n': ");
				ans = readln()[0];
			} while(ans != 'n' && ans != 'N');

	}
}

static if (MUTATION_TEST)
{
	unittest 
	{
		import std.process;
		import ant.progtype;
			
		class VoidOp : Operator
		{
			this()
			{
				mRetType = new TypePod!int;
				super("v","",ArgsStyle.CLASSIC_STYLE);
				
				ArgInfo a1;
				a1.type = mRetType;
				a1.min = "-1000";
				a1.max = "+1000";
				
				args ~= a1;
				args ~= a1;
				args ~= a1;
			}
		
			Argument apply(IndAbstract ind, Line line, WorldAbstract world)
			{
				auto arg = mRetType.getNewArg();
				return arg;
			}	
		
		}
		
			auto tm = new TypeMng;
			auto em = new Evolutor;
			//tm.registerType!(TypePod!int);
		
			AntProgType ptype = new AntProgType();
			Ant pInd = new Ant();
			
			auto op = new VoidOp;
			auto nline0 = new Line;
			auto nline1 = new Line;
			auto nline2 = new Line;
			auto nline3 = new Line;

			
			nline0.operator = op;
			nline1.operator = op;
			nline2.operator = op;
			nline3.operator = op;
			
			nline0[0] = nline1;
			nline0[1] = op.mRetType.getNewArg("1","1",[]);
			nline0[2] = op.mRetType.getNewArg("2","2",[]);
			
			nline1[0] = op.mRetType.getNewArg("3","3",[]);
			nline1[1] = nline2;
			nline1[2] = nline3;
			
			nline2[0] = op.mRetType.getNewArg("4","4",[]);
			nline2[1] = op.mRetType.getNewArg("5","5",[]);
			nline2[2] = op.mRetType.getNewArg("6","6",[]);
			
			nline3[0] = op.mRetType.getNewArg("7","7",[]);
			nline3[1] = op.mRetType.getNewArg("8","8",[]);
			nline3[2] = op.mRetType.getNewArg("9","9",[]);
				
			pInd.program = pInd.program ~ nline0;
			char ans;
			
			do
			{
				version(linux)
					system("clear");
				
				writeln("Было: ");
				writeln(nline0.tostring);	
				em.mutationStd( pInd, ptype );
				
				writeln("Стало: ");
				writeln(nline0.tostring);
				
				write("Для остновки введите 'n': ");
				ans = readln()[0];
			} while(ans != 'n' && ans != 'N');

	}
}

static if (CROSSINGOVER_TEST)
{
	unittest 
	{
		import std.process;
		import ant.progtype;
			
		class VoidOp : Operator
		{
			this()
			{
				mRetType = new TypePod!int;
				super("v","",ArgsStyle.CLASSIC_STYLE);
				
				ArgInfo a1;
				a1.type = mRetType;
				a1.min = "-1000";
				a1.max = "+1000";
				
				args ~= a1;
				args ~= a1;
				args ~= a1;
			}
		
			Argument apply(IndAbstract ind, Line line, WorldAbstract world)
			{
				auto arg = mRetType.getNewArg();
				return arg;
			}	
		
		}
		
			auto tm = new TypeMng;
			auto em = new Evolutor;
			//tm.registerType!(TypePod!int);
		
			AntProgType ptype = new AntProgType();
			Ant pIndA = new Ant();
			Ant pIndB = new Ant();
			
			auto op = new VoidOp;
			auto nline0 = new Line;
			auto nline1 = new Line;
			auto nline2 = new Line;
			auto nline3 = new Line;

			
			nline0.operator = op;
			nline1.operator = op;
			nline2.operator = op;
			nline3.operator = op;
			
			nline0[0] = nline1;
			nline0[1] = op.mRetType.getNewArg("1","1",[]);
			nline0[2] = op.mRetType.getNewArg("2","2",[]);
			
			nline1[0] = op.mRetType.getNewArg("3","3",[]);
			nline1[1] = nline2;
			nline1[2] = nline3;
			
			nline2[0] = op.mRetType.getNewArg("4","4",[]);
			nline2[1] = op.mRetType.getNewArg("5","5",[]);
			nline2[2] = op.mRetType.getNewArg("6","6",[]);
			
			nline3[0] = op.mRetType.getNewArg("7","7",[]);
			nline3[1] = op.mRetType.getNewArg("8","8",[]);
			nline3[2] = op.mRetType.getNewArg("9","9",[]);
				
			pIndA.program = pIndA.program ~ nline0.dup;
			pIndB.program = pIndB.program ~ nline1.dup;
			
			char ans;
			
			do
			{
				version(linux)
					system("clear");
				
				writeln("Было: ");
				writeln("Индивид А: ",pIndA.programString());
				writeln("Индивид B: ",pIndB.programString());
				
				em.crossingoverStd( pIndA, pIndB, ptype );
				
				writeln("Стало: ");
				writeln("Индивид А: ",pIndA.programString());
				writeln("Индивид B: ",pIndB.programString());
				
				write("Для остновки введите 'n': ");
				ans = readln()[0];
			} while(ans != 'n' && ans != 'N');

	}
}

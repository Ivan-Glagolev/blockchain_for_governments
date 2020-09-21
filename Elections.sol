pragma solidity >=0.6.0 <0.8.0;
// SPDX-License-Identifier: GlagolevIvanAlexeevich2001

/* 
Договоримся, что Имя и Фамилию будем отправлять в следующем формате:

NamSur

Первые три буквы имени и первые три буквы фамилии биз пробелов, имя и фамилия начинются с заглавных букв

NB! Сделать функцию selectWinner
*/



/*структура (ключ => значение)*/
struct IndexValue
{
    uint keyIndex;                                      // порядковый индекс ключа элемента
    uint value;                                         // значение элемента
}

/*структура (ключ => существование_элемента)*/
struct KeyFlag
{
    uint key;                                           // ключ элемента
    bool deleted;                                       // флаг: true - удалён элемент, false - элемент существует
}

/*структура общая*/
struct itmap
{
    mapping(uint=>IndexValue) data;
    KeyFlag [] keys;
    uint size;
}

library IterableMapping {
    function insert(itmap storage self, uint key, uint value) internal returns (bool replaced) {
        uint keyIndex = self.data[key].keyIndex;        // создаём временную переменную, хранящую порядковый индекс добавляемого элемента с передаваемым в функцию ключем key
        self.data[key].value = value;                   // присваиваем VALUE
        if (keyIndex > 0)                               // сущестует уже элемент с таким ключем? (по умолчанию keyIndex == 0)
            return true; 
        else {
            keyIndex = self.keys.length;                // элемент существует, поэтому пусть порядковый индекс добавляемого элемента будет равен длине масива KeyFlag
            self.keys.push();                           // добавляем вновь инициализированный элемент структуры KeyFlag в конец массива keys, состоящего из этих структур
            self.data[key].keyIndex = keyIndex + 1;     // присваиваем KEYINDEX (индекс нового элемента = индекс последнего элемента + 1)
            self.keys[keyIndex].key = key;              // присваиваем KEY
            self.size++;                                // +1 элемент к существующему объёму данных
            return false;
        }                                               // NB! deleted по умолчанию устанавливается на 0 в операции self.keys.push();
    }
                                                        
    function remove (itmap storage self, uint key) internal returns(bool success) {
        uint keyIndex = self.data[key].keyIndex;        // создаём временную переменную, хранящую порядковый индекс удаляемого элемента с передаваемым в функцию ключем key
        if(keyIndex == 0) return false;                 // если порядковый индекс элемента установлен на значение по умолчанию (эл-та нет) то возвращаем НЕУДАЧУ удаления
        delete self.data[key];                          // УДАЛИТЬ элемент с передаваемым в функцию ключем KEY
        self.keys[keyIndex - 1].deleted = true;         // ПОМЕТИТЬ, что элемент с индексом keyIndex (-1 потому что начинаем с нуля) удалён, т.е. флаг_удадён ставим на true
        self.size --;                                   // -1 элемент от существующего объёма данных
    }
    /*кажется, это НЕ верная функция*/
    function contains(itmap storage self, uint key) internal view returns(bool) { 
        return self.data[key].keyIndex > 0;
    }
    /*возвращает true если порядковый индекс сейчас рассматриваемого элемента МЕНЬШЕ чем длина*/ 
    function iterate_valid(itmap storage self, uint keyIndex) internal view returns(bool) {
        return keyIndex < self.keys.length;
    }
    
    /*возвращает ключ и значение элемена если передать порядковый индекс сейчас рассматриваемого элемента*/ 
    function iterate_get(itmap storage self, uint keyIndex)internal view returns(uint key, uint value) {
        key = self.keys[keyIndex].key;
        value = self.data[key].value;
    }
    /*возвращает первый порядковый индекс первого (нулевого) элемента*/ 
    function iterate_start(itmap storage self) internal view returns(uint keyIndex) 
    {
        return iterate_next(self,uint(-1));
    }
    /*возвращает следующий порядковый индекс СУЩЕСТВУЮЩЕГО ЭЛЕМЕНТА после рассматриваемого элемента*/ 
    function iterate_next(itmap storage self, uint keyIndex) internal view returns(uint r_keyIndex) 
    {
        do keyIndex++;                                                                      //сначала увеличиваем порядковый индекс рассматриваемого элемента
        while (keyIndex < self.keys.length && ( self.keys[keyIndex].deleted == true ));     //и повторим если следующий (флаг_удадён == true)
        
        return keyIndex;
    }
}


contract ElectionsMissWorld {
    
    address public Manager;
    
    enum State_1 {Running, Ended}
    State_1 public ElectionsState;
    
    mapping (uint=>uint) Winner;
    
    enum State_2 {Voted, DidntVote}
    State_2 internal VouterState;
    mapping (address => State_2) internal Vouter;

    itmap data;
    using IterableMapping for itmap;
    
    constructor() public {
        Manager = msg.sender;
        ElectionsState = State_1.Running;
    }
    
    modifier onlyManager(){
        require(msg.sender == Manager);
        _;
    } 
    modifier notManager(){
        require(msg.sender != Manager);
        _;
    } 
    modifier StateRunning(){
        require(ElectionsState == State_1.Running);
        _;
    }
    modifier VouterDidnVote() {
        require(VouterState == State_2.DidntVote);
        _;
    }
    
    function toVote(uint k, uint v)public VouterDidnVote returns(uint size) {
        data.insert(k, v);
        VouterState = State_2.Voted;
        return data.size;
    }
    
    /*
    function runForElections (string memory NamSur) public notManager StateRunning returns(string memory){ //Баллотироваться
    bool existence = Exist(NamSur);
        if (existence = true) {
            return "Attention! you have already been run for elections!";
        } else {
            MissWorld[NamSur] = 1;
            return "Ok, you run for elections! Congrats!";
        }
    }
    */
    
}

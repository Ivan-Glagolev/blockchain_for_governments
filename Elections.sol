pragma solidity >=0.7.1 <0.8.0;
// SPDX-License-Identifier: GlagolevIvanAlexeevich2001

/*структура (ключ => значение)*/
struct IndexValue{
    uint keyIndex;                                      // порядковый индекс ключа элемента
    uint value;                                         // значение элемента
}

/*структура (ключ => существование_элемента)*/
struct KeyFlag{
    uint key;                                           // ключ элемента
    bool deleted;                                       // флаг: true - удалён элемент, false - элемент существует
}

/*структура общая*/
struct itmap{
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
    
    function addOneVote (itmap storage self, uint key) internal returns(bool) {
        uint keyIndex = self.data[key].keyIndex;
        if(keyIndex == 0) return false;
        self.data[key].value ++;
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
    struct Winner {
        uint key;
        uint votes;
    }
    Winner WinnerOne;
    
    enum State_1 {Running, Ended}
    State_1 public ElectionsState;
    
    enum State_2 {DidntVote, Voted}
    mapping (address => State_2) internal Vouter;
    
    enum State_3 {DidntRun, AlreadyRun}
    mapping (address => State_3) internal Candidate;
    
    itmap data;
    using IterableMapping for itmap;
    
    constructor() {
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
    modifier StateEnded(){
        require(ElectionsState == State_1.Ended);
        _;
    }
    modifier UserStateCorrect() {
        require( (Vouter[msg.sender] == State_2.DidntVote) && (Candidate[msg.sender] == State_3.DidntRun) );
        _;
    }
    
    function RunForElections(uint k)public UserStateCorrect StateRunning returns(uint size) {
        data.insert(k, 1);
        Candidate[msg.sender] = State_3.AlreadyRun;
        return data.size;
    }
    
    function ToVote(uint k) public UserStateCorrect returns (uint){
        data.addOneVote(k);
        Vouter[msg.sender] = State_2.Voted;
        return data.size;
    }
    
    function GetState() public view onlyManager returns (uint) {
        return data.keys.length;
    }
    
    function GetInfoOfCandidate(uint key)public view returns (uint value) {
         value = data.data[key].value;
    }
    
    function StopElections() public onlyManager StateRunning returns (uint KeyWinner, uint ValueWinner){
        ElectionsState = State_1.Ended;
        SelectWinner();
        KeyWinner = WinnerOne.key;
        ValueWinner = WinnerOne.votes;
    }
    
    function SelectWinner () internal StateEnded {
        for (uint i = data.iterate_start(); data.iterate_valid(i); i = data.iterate_next(i)) {
            (uint key, uint value) = data.iterate_get(i);
            if (WinnerOne.votes <= value) {
                WinnerOne.votes = value;
                WinnerOne.key = key;
            }
        }
    }
    
}

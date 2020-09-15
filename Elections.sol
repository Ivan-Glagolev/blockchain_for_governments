pragma solidity ^0.7.1;
// SPDX-License-Identifier: GlagolevIvan

/* 
README

Договоримся, что Имя и Фамилию будем отправлять в следующем формате:

NamSur

Первые три буквы имени и первые три буквы фамилии биз пробелов, имя и фамилия начинются с заглавных букв
*/

contract ElectionsMissWorld {
    
    address public Manager;
    enum State {Running, Ended}
    State public ElectionsState;
    
    mapping(string => uint) [] public MissWorld;
    uint WinnerName;
    
    
    constructor(){                                          //Выполняется однажды при развертывании 
        Manager = msg.sender;
        ElectionsState = State.Running;
    }
    
    modifier onlyManager(){                                 //Проверка на наличие статуса манагера
        require(msg.sender == Manager);
        _;
    }
    
    modifier notManager(){                                  //Проверка на наличие статуса НЕ манагера
        require(msg.sender != Manager);
        _;
    }
    
    modifier StateRunning(){                                 //Проверка на наличие статуса манагера
        require(ElectionsState == State.Running);
        _;
    }
    
    modifier StateEnded(){                                 //Проверка на наличие статуса манагера
        require(ElectionsState == State.Ended);
        _;
    }
    
    function vote () public notManager{                     //Отдать голос за ИмяФам
        
    }
    
    function runForElections () public notManager{          //Баллотироваться
        
    }
    
    function getState () public view onlyManager returns (State) 
    {               
        return ElectionsState;
    }
    
    function selectWinner() public onlyManager{             //Выбрать победителя и завершить голосование
        
    }
    
    
}

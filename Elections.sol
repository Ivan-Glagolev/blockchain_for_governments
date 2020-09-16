pragma solidity ^0.7.1;
// SPDX-License-Identifier: GlagolevIvan

/* 
README

Договоримся, что Имя и Фамилию будем отправлять в следующем формате:

NamSur

Первые три буквы имени и первые три буквы фамилии биз пробелов, имя и фамилия начинются с заглавных букв
*/

/*
NB! Сделать учет адреса msg.sender для предотвращения вбросов "пачками"
*/

/*
NB! Getter функции создаются автоматически при развертывании контракта
только для PUBLIC переменных в STORAGE
*/

/*
NB! Сделать функцию selectWinner
*/

contract ElectionsMissWorld {
    
    address public Manager;
    enum State {Running, Ended}
    State public ElectionsState;
    
    
    
    mapping(string => uint) public MissWorld;
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
    modifier StateRunning(){                               //Проверка ИДУТ ЛИ выборы?
        require(ElectionsState == State.Running);
        _;
    }
    modifier StateEnded(){                                 //Проверка ЗАВЕРШЕНЫ ЛИ выборы?
        require(ElectionsState == State.Ended);
        _;
    }
    
    function Exist(string memory Name) public StateRunning returns(bool){ //Существует тот за кого голосуем?
        bool existance = false;
        if (MissWorld[Name] > 0){
            existance = true;
        }
        return existance;
    }
    
    function vote(string memory NamSur) public notManager StateRunning{ //Проголосовать
        require(Exist(NamSur, MissWorld) = true);
        MissWorld(NamSur)++;
    }
    
    function runForElections (string memory NamSur) public notManager StateRunning returns(string memory){ //Баллотироваться
        if (Exist(NamSur, MissWorld) = 1) {
            return "Attention! you have already been run for elections!";
        } else {
            MissWorld.push(NamSur, 1);
            return "Ok, you run for elections! Congrats!";
        }
    }
    
    
}

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
    
    
    
    mapping(string => uint16) public MissWorld;
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
    
    function Exist(string memory Name, mapping(string=>uint16) NamesAndVotes) public StateRunning returns(bool){
        bool existance = 0;
        if (NamesAndVotes(Name) = uint16){
            existance = 1;
        }
        return existance;
    }
    
    function vote(string memory NamSur) public notManager StateRunning{
        require(Exist(NamSur, MissWorld) = 1);
        MissWorld(NamSur)++;
    }
    
    function runForElections (string memory NamSur) public notManager StateRunning returns(string memory){
        if (Exist(NamSur, MissWorld) = 1) {
            return "Attention! you have already been run for elections!";
        } else {
            MissWorld.push(NamSur, 1);
            return "Ok, you run for elections! Congrats!";
        }
    }
    
    
}

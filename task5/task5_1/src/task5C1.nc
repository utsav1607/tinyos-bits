#include <Timer.h>
#include "task5.h"
#include "printf.h"
#include <stdlib.h>

module task5C1{
	uses interface Boot;
	uses interface Leds;
	uses interface Timer<TMilli> as Timer0;
	uses interface Timer<TMilli> as Timer1;
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface SplitControl as AMControl;
	uses interface Receive;
}
implementation{
	int z=0;
	uint8_t tosend=0;
	bool mul=FALSE;
	message_t pkt;
	am_addr_t x;
	uint8_t counter=0;
	uint8_t precnt=0;
	int hops=0;
	int i=0;
	
	
	event void Boot.booted(){
			task5CMsg* btrpkt = (task5CMsg*)(call Packet.getPayload(&pkt, sizeof (task5CMsg)));
			btrpkt->sourceid0=TOS_NODE_ID;
			btrpkt->sourceid1=0;
			btrpkt->sourceid2=0;
			btrpkt->sourceid3=0;
			btrpkt->sourceid4=0;
			btrpkt->sourceid5=0;
			btrpkt->sourceid6=0;
			btrpkt->sourceid7=0;
			btrpkt->sourceid8=0;
			btrpkt->sourceid9=0;
			btrpkt->sourceid10=0;
			btrpkt->sourceid11=0;
			btrpkt->hopcnt=1;
			if(TOS_NODE_ID==1)
			btrpkt->counter=counter;
			else
			btrpkt->counter=precnt;
			hops=1;
		if((TOS_NODE_ID==13) || (TOS_NODE_ID==14) || (TOS_NODE_ID==15)){
			tosend=TOS_NODE_ID+1;
			mul=FALSE;
		}else if((TOS_NODE_ID==4) || (TOS_NODE_ID==8) || (TOS_NODE_ID==12)){
			tosend=TOS_NODE_ID+4;
			mul=FALSE;
		}else{
			mul=TRUE;
		}
		call AMControl.start();
	}

	event void AMControl.startDone(error_t error){
		if(error==SUCCESS){

			call Leds.led1On();
		}else{
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t error){
		call Leds.led1Off();
	}
	
	event void Timer0.fired(){
		task5CMsg* reqd = (task5CMsg*)(call Packet.getPayload(&pkt, sizeof (task5CMsg)));
		counter++;
		if(mul){
			if(z==0){
			tosend=TOS_NODE_ID+1;
			z=1;
			}else if(z==1){
			tosend=TOS_NODE_ID+4;
			z=0;
			}
		}
		printfflush();
		printf("%u-%u-%u-%u%u%u%u%u%u%u\n",hops,reqd->counter,tosend,reqd->sourceid0,reqd->sourceid1,reqd->sourceid2,reqd->sourceid3,reqd->sourceid4,reqd->sourceid5,reqd->sourceid6);
		if(call AMSend.send(tosend,&pkt, sizeof(task5CMsg))==SUCCESS){	
			call Leds.led2Toggle();
			call AMControl.stop();
			call Timer1.startOneShot(5000);
			}
	}
	
	event void Timer1.fired(){
		call AMControl.start();
	}

	event void AMSend.sendDone(message_t *msg, error_t error){
		if(error==SUCCESS){
			task5CMsg* btrpkt = (task5CMsg*)(call Packet.getPayload(&pkt, sizeof (task5CMsg)));
			btrpkt->sourceid0=TOS_NODE_ID;
			btrpkt->sourceid1=0;
			btrpkt->sourceid2=0;
			btrpkt->sourceid3=0;
			btrpkt->sourceid4=0;
			btrpkt->sourceid5=0;
			btrpkt->sourceid6=0;
			btrpkt->sourceid7=0;
			btrpkt->sourceid8=0;
			btrpkt->sourceid9=0;
			btrpkt->sourceid10=0;
			btrpkt->sourceid11=0;
			btrpkt->hopcnt=1;
			if(TOS_NODE_ID==1)
			btrpkt->counter=counter;
			else
			btrpkt->counter=precnt;	
			hops=1;
		}
	}

	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len){
		x=call AMPacket.source(msg);
		if(x==16){
			call Timer0.startPeriodicAt(TOS_NODE_ID*TIMER_PERIOD_MILLI,20000);
		}else{
			task5CMsg* btrpkt=(task5CMsg*)payload;
				task5CMsg* reqd = (task5CMsg*)(call Packet.getPayload(&pkt, sizeof (task5CMsg)));
				if(hops==1){//////IF HOPS then IF HOPCNTR
					for(i=1;i<(btrpkt->hopcnt)+1;i++){
						switch(i){
							case(1):reqd->sourceid1=btrpkt->sourceid0;
								break;
							case(2):reqd->sourceid2=btrpkt->sourceid1;
								break;
							case(3):reqd->sourceid3=btrpkt->sourceid2;
								break;
							case(4):reqd->sourceid4=btrpkt->sourceid3;
								break;
							case(5):reqd->sourceid5=btrpkt->sourceid4;
								break;
							case(6):reqd->sourceid6=btrpkt->sourceid5;
								break;
							case(7):reqd->sourceid7=btrpkt->sourceid6;
								break;
							case(8):reqd->sourceid8=btrpkt->sourceid7;
								break;
						}
					}
				}else if(hops==3){//////IF HOPS then IF HOPCNTR
					for(i=1;i<(btrpkt->hopcnt)+1;i++){
						switch(i){
							case(1):reqd->sourceid3=btrpkt->sourceid0;
								break;
							case(2):reqd->sourceid4=btrpkt->sourceid1;
								break;
							case(3):reqd->sourceid5=btrpkt->sourceid2;
								break;
							case(4):reqd->sourceid6=btrpkt->sourceid3;
								break;
							case(5):reqd->sourceid7=btrpkt->sourceid4;
								break;
							case(6):reqd->sourceid8=btrpkt->sourceid5;
								break;
							case(7):reqd->sourceid9=btrpkt->sourceid6;
								break;
							case(8):reqd->sourceid10=btrpkt->sourceid7;
								break; 
						}
					}
				}else if(hops==2){//////IF HOPS then IF HOPCNTR
					for(i=1;i<(btrpkt->hopcnt)+1;i++){
						switch(i){
							case(1):reqd->sourceid2=btrpkt->sourceid0;
								break;
							case(2):reqd->sourceid3=btrpkt->sourceid1;
								break;
							case(3):reqd->sourceid4=btrpkt->sourceid2;
								break;
							case(4):reqd->sourceid5=btrpkt->sourceid3;
								break;
							case(5):reqd->sourceid6=btrpkt->sourceid4;
								break;
							case(6):reqd->sourceid7=btrpkt->sourceid5;
								break;
							case(7):reqd->sourceid8=btrpkt->sourceid6;
								break;
							case(8):reqd->sourceid9=btrpkt->sourceid7;
								break;
						}
					}
				}else if(hops==4){//////IF HOPS then IF HOPCNTR
					for(i=1;i<(btrpkt->hopcnt)+1;i++){
						switch(i){
							case(1):reqd->sourceid4=btrpkt->sourceid0;
								break;
							case(2):reqd->sourceid5=btrpkt->sourceid1;
								break;
							case(3):reqd->sourceid6=btrpkt->sourceid2;
								break;
							case(4):reqd->sourceid7=btrpkt->sourceid3;
								break;
							case(5):reqd->sourceid8=btrpkt->sourceid4;
								break;
							case(6):reqd->sourceid9=btrpkt->sourceid5;
								break;
							case(7):reqd->sourceid10=btrpkt->sourceid6;
								break;
						}					
					}
				}else if(hops==5){
					for(i=1;i<(btrpkt->hopcnt)+1;i++){
						switch(i){
							case(1):reqd->sourceid5=btrpkt->sourceid0;
								break;
							case(2):reqd->sourceid6=btrpkt->sourceid1;
								break;
							case(3):reqd->sourceid7=btrpkt->sourceid2;
								break;
							case(4):reqd->sourceid8=btrpkt->sourceid3;
								break;
							case(5):reqd->sourceid9=btrpkt->sourceid4;
								break;
							case(6):reqd->sourceid10=btrpkt->sourceid5;
								break;
							case(7):reqd->sourceid11=btrpkt->sourceid6;
								break;
						}					
					}
				}else{
				for(i=1;i<(btrpkt->hopcnt)+1;i++){
						switch(i){
							case(1):reqd->sourceid5=btrpkt->sourceid0;
								break;
							case(2):reqd->sourceid6=btrpkt->sourceid1;
								break;
							case(3):reqd->sourceid7=btrpkt->sourceid2;
								break;
							case(4):reqd->sourceid8=btrpkt->sourceid3;
								break;
							case(5):reqd->sourceid9=btrpkt->sourceid4;
								break;
							case(6):reqd->sourceid10=btrpkt->sourceid5;
								break;
							case(7):reqd->sourceid11=btrpkt->sourceid6;
								break;
						}					
					}
				}
				if((btrpkt->counter)>=(reqd->counter)){
					reqd->counter=btrpkt->counter;
					precnt=btrpkt->counter;
				}
				else
					reqd->counter=precnt;
				hops=hops+btrpkt->hopcnt;
				reqd->hopcnt=hops;
				call Leds.led0Toggle();
			
			}
		return msg;
	}
}

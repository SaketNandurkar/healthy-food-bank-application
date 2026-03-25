import { Injectable } from '@angular/core';
import { Client, IMessage } from '@stomp/stompjs';
import { BehaviorSubject, Observable } from 'rxjs';

declare const SockJS: any;

@Injectable({
  providedIn: 'root'
})
export class WebSocketService {
  private client: Client;
  private productUpdateSubject = new BehaviorSubject<any>(null);
  private orderNotificationSubject = new BehaviorSubject<any>(null);

  constructor() {
    this.client = new Client({
      webSocketFactory: () => new SockJS('http://localhost:9090/ws'),
      connectHeaders: {},
      debug: (str) => {
        console.log('WebSocket Debug:', str);
      },
      reconnectDelay: 5000,
      heartbeatIncoming: 4000,
      heartbeatOutgoing: 4000,
    });

    this.client.onConnect = (frame) => {
      console.log('Connected to WebSocket: ' + frame);
      this.subscribeToProductUpdates();
    };

    this.client.onStompError = (frame) => {
      console.error('WebSocket STOMP Error: ' + frame.headers['message']);
      console.error('Error details: ' + frame.body);
    };

    this.client.onWebSocketError = (error) => {
      console.error('WebSocket Error: ', error);
    };

    this.client.onDisconnect = (frame) => {
      console.log('Disconnected from WebSocket: ' + frame);
    };
  }

  connect(): void {
    if (!this.client.connected) {
      this.client.activate();
    }
  }

  disconnect(): void {
    if (this.client.connected) {
      this.client.deactivate();
    }
  }

  private subscribeToProductUpdates(): void {
    this.client.subscribe('/topic/products', (message: IMessage) => {
      const productData = JSON.parse(message.body);
      console.log('Received product update:', productData);
      this.productUpdateSubject.next(productData);
    });

    this.client.subscribe('/topic/vendor-orders', (message: IMessage) => {
      const orderData = JSON.parse(message.body);
      console.log('Received vendor order notification:', orderData);
      this.orderNotificationSubject.next(orderData);
    });
  }

  getProductUpdates(): Observable<any> {
    return this.productUpdateSubject.asObservable();
  }

  getOrderNotifications(): Observable<any> {
    return this.orderNotificationSubject.asObservable();
  }

  isConnected(): boolean {
    return this.client.connected;
  }
}
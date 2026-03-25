package user_service.controller;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

@Controller
public class NotificationController {

    //server application
///app/sendMessage
    ///app/sendMessage
//    @MessageMapping("/sendMessage")
//    @SendTo("/topic/progress")
//    public String sendMessage(String message){
//        System.out.println("message : "+message);
//        return message;
//    }

    private final SimpMessagingTemplate simpMessagingTemplate;

    public NotificationController(SimpMessagingTemplate simpMessagingTemplate) {
        this.simpMessagingTemplate = simpMessagingTemplate;
    }

    // Endpoint to handle client-sent messages to /app/sendMessage
    @MessageMapping("/sendMessage")
    @SendTo("/topic/progress") // Broadcast to clients subscribed to /topic/progress
    public String sendMessage(String message) {
        System.out.println("Received message from client: " + message);
        return "Message from server: " + message; // This is what clients will receive
    }

    // Utility method to programmatically send messages to clients
    public void notifyClients(String message) {
        simpMessagingTemplate.convertAndSend("/topic/progress", message);
    }

    // REST endpoint for product notifications
    @PostMapping("/api/notify/product-added")
    @CrossOrigin(origins = {"http://localhost:4200", "http://127.0.0.1:4200", "http://localhost:9091"})
    @ResponseBody
    public void notifyProductAdded(@RequestBody Object productData) {
        // Broadcast to all users that a new product was added
        simpMessagingTemplate.convertAndSend("/topic/products", productData);
    }

    @PostMapping("/api/notify/product-updated")
    @CrossOrigin(origins = {"http://localhost:4200", "http://127.0.0.1:4200", "http://localhost:9091"})
    @ResponseBody
    public void notifyProductUpdated(@RequestBody Object productData) {
        // Broadcast to all users that a product was updated
        simpMessagingTemplate.convertAndSend("/topic/products", productData);
    }

    @PostMapping("/api/notify/product-deleted")
    @CrossOrigin(origins = {"http://localhost:4200", "http://127.0.0.1:4200", "http://localhost:9091"})
    @ResponseBody
    public void notifyProductDeleted(@RequestBody Object productData) {
        // Broadcast to all users that a product was deleted
        simpMessagingTemplate.convertAndSend("/topic/products", productData);
    }

    // REST endpoint for order notifications to vendors
    @PostMapping("/api/notify/order-placed")
    @CrossOrigin(origins = {"http://localhost:4200", "http://127.0.0.1:4200", "http://localhost:9092"})
    @ResponseBody
    public void notifyOrderPlaced(@RequestBody Object orderData) {
        System.out.println("Order notification received: " + orderData);
        // Broadcast to vendors that a new order was placed
        simpMessagingTemplate.convertAndSend("/topic/vendor-orders", orderData);
    }

    @PostMapping("/api/notify/order-updated")
    @CrossOrigin(origins = {"http://localhost:4200", "http://127.0.0.1:4200", "http://localhost:9092"})
    @ResponseBody
    public void notifyOrderUpdated(@RequestBody Object orderData) {
        System.out.println("Order update notification received: " + orderData);
        // Broadcast to vendors that an order status was updated
        simpMessagingTemplate.convertAndSend("/topic/vendor-orders", orderData);
    }
}

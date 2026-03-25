package product_service.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI productServiceOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Healthy Food Bank - Product Service API")
                        .description("API documentation for Product Service - handles product catalog, inventory management, and product operations")
                        .version("v1.0.0")
                        .contact(new Contact()
                                .name("HFB Development Team")
                                .email("dev@healthyfoodbank.com")
                                .url("https://healthyfoodbank.com"))
                        .license(new License()
                                .name("Apache 2.0")
                                .url("https://www.apache.org/licenses/LICENSE-2.0")))
                .servers(List.of(
                        new Server().url("http://localhost:9091").description("Development Server"),
                        new Server().url("https://api.healthyfoodbank.com").description("Production Server")))
                .addSecurityItem(new SecurityRequirement().addList("User ID Header"))
                .components(new io.swagger.v3.oas.models.Components()
                        .addSecuritySchemes("User ID Header",
                                new SecurityScheme()
                                        .type(SecurityScheme.Type.APIKEY)
                                        .in(SecurityScheme.In.HEADER)
                                        .name("X-User-Id")
                                        .description("User ID for product operations")));
    }
}
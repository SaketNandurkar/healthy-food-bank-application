package order_service.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import java.security.Key;

/**
 * JWT utility for extracting claims from tokens
 * Uses the same secret key as user-service for token validation
 */
@Component
public class JwtUtil {

    // IMPORTANT: This must match the SECRET in user-service JwtService
    private static final String SECRET = "364f76e32e4c95b9c477c134dccbe89535629e160ec90569996ca4ca682d1c47dae31186543787623c39a1dbd242a24b164e122f650f32c40c05567adfcc8e9c6999376c567f918371ab5b879c54d02002d3e4f952ef544a5a2a6961199235c8c5b1d9529f7b5079848e072826fd737bf4ff4805da372e325839a8b3968f78283543d583749e93acf71c1033247dab9d4260117316c2495a3455afa20b0fbe410c00c3dea5f40f653030f214fe50f736fd58c703d11b32197d587dbd316cc2dbc2d8752909821813d4bb92e25473dcaeaaf6ccb1644f23e09561a20c3e855e9a0f0aacae2ea1f0f81f9e615b0fad85fb8ca1fa601990ae357e399cddc7aa0410";

    /**
     * Extract vendorId from JWT token
     * @param token JWT token (with or without "Bearer " prefix)
     * @return vendorId if present, null otherwise
     */
    public String extractVendorId(String token) {
        try {
            // Remove "Bearer " prefix if present
            String cleanToken = token.startsWith("Bearer ") ? token.substring(7) : token;
            Claims claims = extractAllClaims(cleanToken);
            return claims.get("vendorId", String.class);
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Extract username from JWT token
     * @param token JWT token (with or without "Bearer " prefix)
     * @return username (subject)
     */
    public String extractUsername(String token) {
        try {
            String cleanToken = token.startsWith("Bearer ") ? token.substring(7) : token;
            Claims claims = extractAllClaims(cleanToken);
            return claims.getSubject();
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Extract role from JWT token
     * @param token JWT token (with or without "Bearer " prefix)
     * @return role if present, null otherwise
     */
    public String extractRole(String token) {
        try {
            String cleanToken = token.startsWith("Bearer ") ? token.substring(7) : token;
            Claims claims = extractAllClaims(cleanToken);
            return claims.get("role", String.class);
        } catch (Exception e) {
            return null;
        }
    }

    private Claims extractAllClaims(String token) {
        return Jwts.parser()
                .setSigningKey(getSignKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    private Key getSignKey() {
        byte[] keyBytes = Decoders.BASE64.decode(SECRET);
        return Keys.hmacShaKeyFor(keyBytes);
    }
}

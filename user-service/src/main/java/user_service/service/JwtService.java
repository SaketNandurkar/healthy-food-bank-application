package user_service.service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Component
public class JwtService {

    private static String SECRET = "364f76e32e4c95b9c477c134dccbe89535629e160ec90569996ca4ca682d1c47dae31186543787623c39a1dbd242a24b164e122f650f32c40c05567adfcc8e9c6999376c567f918371ab5b879c54d02002d3e4f952ef544a5a2a6961199235c8c5b1d9529f7b5079848e072826fd737bf4ff4805da372e325839a8b3968f78283543d583749e93acf71c1033247dab9d4260117316c2495a3455afa20b0fbe410c00c3dea5f40f653030f214fe50f736fd58c703d11b32197d587dbd316cc2dbc2d8752909821813d4bb92e25473dcaeaaf6ccb1644f23e09561a20c3e855e9a0f0aacae2ea1f0f81f9e615b0fad85fb8ca1fa601990ae357e399cddc7aa0410";

    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    public String extractVendorId(String token) {
        return extractClaim(token, claims -> claims.get("vendorId", String.class));
    }

    public Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    private Claims extractAllClaims(String token) {
        return Jwts.parser()
                .setSigningKey(getSignKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    private Boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    public Boolean validateToken(String token, UserDetails userDetails) {
        final String username = extractUsername(token);
        boolean isExpired = isTokenExpired(token);
        boolean usernameMatches = username.equals(userDetails.getUsername());

        System.out.println("=== JWT VALIDATION DEBUG ===");
        System.out.println("Token username: '" + username + "'");
        System.out.println("UserDetails username: '" + userDetails.getUsername() + "'");
        System.out.println("Username matches: " + usernameMatches);
        System.out.println("Token expired: " + isExpired);
        System.out.println("Token valid: " + (usernameMatches && !isExpired));
        System.out.println("=== JWT VALIDATION DEBUG END ===");

        return (usernameMatches && !isExpired);
    }

    public String generateToken(String userName, Authentication authentication){
        Map<String, Object> claims = new HashMap<>();
        String authority = authentication.getAuthorities().iterator().next().getAuthority();
        // Remove ROLE_ prefix for JWT storage - frontend expects clean role names
        String role = authority.startsWith("ROLE_") ? authority.substring(5) : authority;
        claims.put("role", role);
        return createToken(claims, userName);
    }

    // Overloaded method to include vendorId in claims
    public String generateToken(String userName, Authentication authentication, String vendorId){
        Map<String, Object> claims = new HashMap<>();
        String authority = authentication.getAuthorities().iterator().next().getAuthority();
        // Remove ROLE_ prefix for JWT storage - frontend expects clean role names
        String role = authority.startsWith("ROLE_") ? authority.substring(5) : authority;
        claims.put("role", role);
        if (vendorId != null && !vendorId.isEmpty()) {
            claims.put("vendorId", vendorId);
        }
        return createToken(claims, userName);
    }

    private String createToken(Map<String, Object> claims, String userName) {
        return Jwts.builder().claims(claims).subject(userName).issuedAt(new Date(System.currentTimeMillis()))
                .expiration(new Date(System.currentTimeMillis()+1000*60*30))
                .signWith(getSignKey()).compact();
    }

    private Key getSignKey() {
        byte[] keyBytes = Decoders.BASE64.decode(SECRET);
        return Keys.hmacShaKeyFor(keyBytes);
    }

}

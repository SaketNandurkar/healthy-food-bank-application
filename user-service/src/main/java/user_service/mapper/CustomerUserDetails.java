package user_service.mapper;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import user_service.entity.Customer;

import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

public class CustomerUserDetails implements UserDetails {

    private String userName;
    private String password;
    private List<GrantedAuthority> authorities;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return userName;
    }

    private Customer customer;

    public CustomerUserDetails(Customer customer){
        userName = customer.getUserName();
        password = customer.getPassword();
        authorities = Arrays.stream(customer.getRoles().split(","))
                .map(role -> new SimpleGrantedAuthority("ROLE_" + role.trim()))
                .collect(Collectors.toList());
        this.customer = customer;
    }

    @Override
    public boolean isAccountNonExpired() {
        return customer.isActive();
    }

    @Override
    public boolean isAccountNonLocked() {
        return customer.isActive();
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return customer.isActive();
    }

    @Override
    public boolean isEnabled() {
        return customer.isActive();
    }

}

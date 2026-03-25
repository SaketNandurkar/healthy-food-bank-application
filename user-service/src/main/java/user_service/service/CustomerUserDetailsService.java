package user_service.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import user_service.entity.Customer;
import user_service.mapper.CustomerUserDetails;
import user_service.repository.CustomerRepository;

import java.util.Optional;

@Service
public class CustomerUserDetailsService implements UserDetailsService {

    @Autowired
    private CustomerRepository customerRepository;

    @Override
    public UserDetails loadUserByUsername(String userName) throws UsernameNotFoundException {
        Optional<Customer> customer = customerRepository.findByUserName(userName);
        return customer.map(CustomerUserDetails::new).orElseThrow(() -> new UsernameNotFoundException("UserName not found"));
    }

}

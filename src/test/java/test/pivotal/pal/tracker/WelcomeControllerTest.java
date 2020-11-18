package test.pivotal.pal.tracker;

import io.pivotal.pal.tracker.WelcomeController;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

public class WelcomeControllerTest {

    @Test
    public void itSaysHello() throws Exception {
        WelcomeController controller = new WelcomeController("hello from kubernetes");
        assertThat(controller.sayHello()).isEqualTo("hello from kubernetes");
        //build commit
    }
}

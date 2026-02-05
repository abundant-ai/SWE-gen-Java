package io.micronaut.test.lombok;

import static org.junit.jupiter.api.Assertions.assertEquals;

import io.micronaut.core.beans.BeanIntrospection;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.UUID;

public class LombokIntrospectedBuilderTest {

    @Test
    void testLombokBuilder() {
        BeanIntrospection.Builder<RobotEntity> builder = BeanIntrospection.getIntrospection(RobotEntity.class)
            .builder();

        RobotEntity robotEntity = builder.with("name", "foo")
            .build();

        assertEquals("foo", robotEntity.getName());
    }

    @Test
    void testLombokBuilder2() {
        BeanIntrospection.Builder<MyEntity> builder = BeanIntrospection.getIntrospection(MyEntity.class)
            .builder();
        MyEntity.MyEntityBuilder builder1 = MyEntity.builder();
        builder.with("name", "foo");
        builder.with("id", "123");
        MyEntity myEntity = builder.build();
        assertEquals("foo", myEntity.getName());
        assertEquals("123", myEntity.getId());
    }

    @Test
    void testLombokBuilderWithInnerClasses() {
        BeanIntrospection.Builder<SimpleEntity> builder = BeanIntrospection.getIntrospection(SimpleEntity.class)
            .builder();

        String id = UUID.randomUUID().toString();
        SimpleEntity simpleEntity = builder.with("id", id)
            .build();

        assertEquals(id, simpleEntity.getId());

        BeanIntrospection<SimpleEntity.CompartmentCreationTimeIndexPrefix> innerClassIntrospection =
            BeanIntrospection.getIntrospection(SimpleEntity.CompartmentCreationTimeIndexPrefix.class);
        Assertions.assertNotNull(innerClassIntrospection);

        BeanIntrospection.Builder<SimpleEntity.CompartmentCreationTimeIndexPrefix> innerClassBuilder =
            innerClassIntrospection.builder();

        long current = Instant.now().toEpochMilli();
        SimpleEntity.CompartmentCreationTimeIndexPrefix innerClassEntity =
            innerClassBuilder.with("compartmentId", "c1").with("timeCreated", current).build();

        assertEquals("c1", innerClassEntity.getCompartmentId());
        assertEquals(current, innerClassEntity.getTimeCreated());
    }
}

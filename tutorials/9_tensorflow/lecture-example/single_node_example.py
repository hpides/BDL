import mnist_setup


def run_worker():
    batch_size = 64
    multi_worker_dataset = mnist_setup.mnist_dataset(batch_size)

    model = mnist_setup.build_and_compile_cnn_model()

    model.summary()

    model.fit(multi_worker_dataset, epochs=20, steps_per_epoch=70)


if __name__ == '__main__':
    run_worker()

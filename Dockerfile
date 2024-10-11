FROM matbun/root:6.32-noble

WORKDIR /dependencies

# Generic dependencies
RUN apt-get update && apt-get install -y \
    tzdata libxt-dev libglx-dev libgl1-mesa-dev \
    libboost-all-dev emacs xvfb x11vnc fvwm libcgal-dev git cmake tk8.6-dev \
    libmpfr-dev libgmp-dev pybind11-dev libxi-dev libxmu-dev python3 python3-pip python3.12-venv \
    software-properties-common && \
    apt-add-repository universe && \
    apt-get update && apt-get install -y doxygen \
    && rm -rf /var/lib/apt/lists/*

# Open cascade from source
RUN git clone https://github.com/Open-Cascade-SAS/OCCT.git && \
    cd OCCT && git checkout V7_8_1 && cd ../ && \
    mkdir OCCT-build && cd OCCT-build && \
    cmake ../OCCT && \
    make -j4 && \
    make install && \
    cd ../ && \
    rm -rf OCCT OCCT-build

# Install paraview (headless)
RUN wget -O paraview.tar.gz "https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v5.13&type=binary&os=Linux&downloadFile=ParaView-5.13.0-egl-MPI-Linux-Python3.10-x86_64.tar.gz" && \
    mkdir paraview && tar xf paraview.tar.gz -C paraview --strip-components 1 && \
    rm paraview.tar.gz
# Make paraview visible
ENV PYTHONPATH=${PYTHONPATH}:/tmp/paraview/lib/python3.10/site-packages
ENV PATH=${PATH}:/tmp/paraview/bin

WORKDIR /app

# Install Python dependencies
RUN python3 -m venv .venv && \
    source .venv/bin/activate && \
    pip install --no-cache-dir cython ipython pybind11 pandas distro vtk

# Vtk
#RUN wget https://www.vtk.org/files/release/9.2/vtk-9.2.0rc1-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl && \
#    pip install --no-cache-dir vtk-9.2.0rc1-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl && \
#    rm vtk-9.2.0rc1-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl

# Install pyg4ometry
RUN source .venv/bin/activate && \
    pip install --no-cache-dir git+https://github.com/g4edge/pyg4ometry pybdsim

ENTRYPOINT ["bash", "-c", "source /app/.venv/bin/activate && \"$@\"", "bash"]

LABEL org.opencontainers.image.source=https://github.com/g4edge/pyg4ometry
LABEL org.opencontainers.image.description="pyg4ometry"
LABEL maintainer="Matteo Bunino - matteo.bunino@cern.ch"
